///bin/true; TMPDIR="$(cd "$(dirname "${0}")" && pwd)" exec /usr/bin/go run "$0" "$@"
package main
import "fmt"
func main() {
    fmt.Println("hello")
}
