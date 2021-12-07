module github.com/haoqing/summary/ocm/placement/tool2

go 1.16

replace open-cluster-management.io/api v0.5.1-0.20211202065430-827eba48608a => github.com/haoqing0110/api v0.0.0-20211206143529-0abc0e9094be

require (
	k8s.io/api v0.22.1
	k8s.io/apimachinery v0.22.1
	k8s.io/client-go v0.22.1
	open-cluster-management.io/api v0.5.1-0.20211202065430-827eba48608a
)
