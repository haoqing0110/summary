package pattern

import "errors"

//type IntSet struct {
//	data map[int]bool
//}
//
//func NewIntSet() IntSet {
//	return IntSet{make(map[int]bool)}
//}
//
//func (set *IntSet) Add(x int) {
//	set.data[x] = true
//}
//
//func (set *IntSet) Delete(x int) {
//	delete(set.data, x)
//}
//
//func (set *IntSet) Contains(x int) bool {
//	return set.data[x]
//}
//
//type UndoableIntSet struct { // Poor style
//	IntSet    // Embedding (delegation)
//	functions []func()
//}
//
//func NewUndoableIntSet() UndoableIntSet {
//	return UndoableIntSet{NewIntSet(), nil}
//}
//
//func (set *UndoableIntSet) Add(x int) { // Override
//	if !set.Contains(x) {
//		set.data[x] = true
//		set.functions = append(set.functions, func() { set.Delete(x) })
//	} else {
//		set.functions = append(set.functions, nil)
//	}
//}
//
//func (set *UndoableIntSet) Delete(x int) { // Override
//	if set.Contains(x) {
//		delete(set.data, x)
//		set.functions = append(set.functions, func() { set.Add(x) })
//	} else {
//		set.functions = append(set.functions, nil)
//	}
//}
//
//func (set *UndoableIntSet) Undo() error {
//	if len(set.functions) == 0 {
//		return errors.New("No functions to undo")
//	}
//	index := len(set.functions) - 1
//	if function := set.functions[index]; function != nil {
//		function()
//		set.functions[index] = nil // For garbage collection
//	}
//	set.functions = set.functions[:index]
//	return nil
//}

// 反转控制IoC – Inversion of Control 是一种软件设计的方法，其主要的思想是把控制逻辑与业务逻辑分享，不要在业务逻辑里写控制逻辑，这样会让控制逻辑依赖于业务逻辑，而是反过来，让业务逻辑依赖控制逻辑。

// 我们先声明一种函数接口，表现我们的Undo控制可以接受的函数签名是什么样的：
type Undo []func()

// 有了上面这个协议后，我们的Undo控制逻辑就可以写成如下：
func (undo *Undo) Add(function func()) {
	*undo = append(*undo, function)
}

func (undo *Undo) Undo() error {
	functions := *undo
	if len(functions) == 0 {
		return errors.New("No functions to undo")
	}
	index := len(functions) - 1
	if function := functions[index]; function != nil {
		function()
		functions[index] = nil // For garbage collection
	}
	*undo = functions[:index]
	return nil
}

// 这里你不必觉得奇怪， Undo 本来就是一个类型，不必是一个结构体，是一个函数数组也没什么问题。
// 然后，我们在我们的IntSet里嵌入 Undo，然后，再在 Add() 和 Delete() 里使用上面的方法，就可以完成功能。
// 这个就是控制反转，不再由 控制逻辑 Undo 来依赖业务逻辑 IntSet，而是由业务逻辑 IntSet 来依赖 Undo 。其依赖的是其实是一个协议，这个协议是一个没有参数的函数数组。我们也可以看到，我们 Undo 的代码就可以复用了。
type IntSet struct {
	data map[int]bool
	undo Undo
}

func NewIntSet() IntSet {
	return IntSet{data: make(map[int]bool)}
}

func (set *IntSet) Undo() error {
	return set.undo.Undo()
}

func (set *IntSet) Contains(x int) bool {
	return set.data[x]
}

func (set *IntSet) Add(x int) {
	if !set.Contains(x) {
		set.data[x] = true
		set.undo.Add(func() { set.Delete(x) })
	} else {
		set.undo.Add(nil)
	}
}

func (set *IntSet) Delete(x int) {
	if set.Contains(x) {
		delete(set.data, x)
		set.undo.Add(func() { set.Add(x) })
	} else {
		set.undo.Add(nil)
	}
}
