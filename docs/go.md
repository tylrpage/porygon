# Go Notes

## Exported Names
- Names are exported if they start with a capital letter

## Declaration Order
- Types come after the variable name
- ex: func mult(x int, y int) int {
    return x * y
}

## Funcion Results
- Functions can return multiple results
- ex: func swap(x string, y string) (string, string) {
    return y, x
}

## Variables
- variables are declared with a "var" statement
    - ex: var i int
- They can be declared at the package or function level