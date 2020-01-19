package main

func main1() {
	var array1 [5]int
	array2 := [5]int{1, 2, 3, 4, 5}
	array3 := [...]int{1, 2, 3, 4, 5, 6}
	array4 := [5]int{1: 10, 3: 30}
	println(array1[0])
	println(array2[1])
	println(array3[2])
	println(array4[3])

	array5 := [5]*int{0: new(int), 1: new(int)}
	*array5[0] = 10
	*array5[1] = 20
	println(array5[0])
	println(*array5[0])

	var array6 [5]string
	array7 := [5]string{"Red", "Blue", "Green", "Yellow", "Pink"}
	array6 = array7
	println(array6[0])
	println(array7[0])
}

func main2() {
	var array1 [4][2]int
	array2 := [4][2]int{{10, 11}, {20, 21}, {30, 31}, {40, 41}}
	println(array1[0][0])
	println(array2[0][0])
}

func main() {
	main1()
	main2()
}
