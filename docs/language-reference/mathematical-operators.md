# OpenSCAD User Manual: Mathematical Operators

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Mathematical_Operators](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Mathematical_Operators)

## Scalar Arithmetic Operators

The scalar arithmetic operators take numbers as operands and produce a new number.

| Operator | Description |
|----------|-------------|
| `+` | Add |
| `-` | Subtract |
| `*` | Multiply |
| `/` | Divide |
| `%` | Modulo |
| `^` | Exponent *(Requires version 2021.01)* |

The `-` can also be used as a prefix operator to negate a number.

Prior to version 2021.01, the builtin mathematical function `pow()` is used instead of the `^` exponent operator.

**Example:**

```openscad
a=[ for(i=[0:10]) i%2 ];
echo(a); // ECHO: [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0]
```

A number modulo 2 is zero if even and one if odd.

## Binary Arithmetic

*(Requires Development snapshot)*

| Operator | Description |
|----------|-------------|
| `\|` | OR |
| `&` | AND |
| `<<` | Left shift |
| `>>` | Right shift (sign preserving) |
| `~` | Unary NOT |

Integer values are converted to at least 64-bit signed integers for binary arithmetic, and then converted back. Note that OpenSCAD numbers have at least 53 bits of precision; binary arithmetic exceeding 2^53 may be imprecise.

## Relational Operators

Relational operators produce a boolean result from two operands.

| Operator | Description |
|----------|-------------|
| `<` | Less than |
| `<=` | Less or equal |
| `==` | Equal |
| `!=` | Not equal |
| `>=` | Greater or equal |
| `>` | Greater than |

**Rules for different types:**

- If both operands are **simple numbers**, the meaning is self-evident.
- If both operands are **strings**, alphabetical sorting determines equality and order. E.g., `"ab" > "aa" > "a"`.
- If both operands are **Booleans**, `true > false`. In an inequality comparison between a Boolean and a number, `true` is treated as 1 and `false` is treated as 0. Other inequality tests involving Booleans return `false`.
- If both operands are **vectors**, an equality test returns `true` when the vectors are identical and `false` otherwise. Inequality tests involving one or two vectors always return `false`, so for example `[1] < [2]` is `false`.
- **Dissimilar types** always test as unequal with `==` and `!=`. Inequality comparisons between dissimilar types, except for Boolean and numbers as noted above, always result in `false`. Note that `[1]` and `1` are different types so `[1] == 1` is `false`.
- **`undef`** doesn't equal anything but `undef`. Inequality comparisons involving `undef` result in `false`.
- **`nan`** doesn't equal anything (not even itself) and inequality tests all produce `false`.

## Logical Operators

All logical operators take Booleans as operands and produce a Boolean. Non-Boolean quantities are converted to Booleans before the operator is evaluated.

| Operator | Description |
|----------|-------------|
| `&&` | Logical AND |
| `\|\|` | Logical OR |
| `!` | Logical unary NOT |

Since `[false]` is `true`, `false || [false]` is also `true`.

Logical operators deal with vectors differently than relational operators:

- `[1, 1] > [0, 2]` is `false`, but
- `[false, false] && [false, false]` is `true`.

## Conditional Operator

The `?:` operator can be used to conditionally evaluate one or another expression. It works like the `?:` operator from the family of C-like programming languages.

```openscad
a=1;
b=2;
c= a==b ? 4 : 5;
```

If `a` equals `b`, then `c` is set to 4, else `c` is set to 5. The part `a==b` must be something that evaluates to a boolean value.

## Vector-Number Operators

The vector-number operators take a vector and a number as operands and produce a new vector.

| Operator | Description |
|----------|-------------|
| `*` | Multiply all vector elements by number |
| `/` | Divide all vector elements by number |

**Example:**

```openscad
L = [1, [2, [3, "a"] ] ];
echo(5*L);
// ECHO: [5, [10, [15, undef]]]
```

## Vector Operators

The vector operators take vectors as operands and produce a new vector.

| Operator | Description |
|----------|-------------|
| `+` | Add element-wise |
| `-` | Subtract element-wise |

The `-` can also be used as a prefix operator to element-wise negate a vector.

**Example:**

```openscad
L1 = [1, [2, [3, "a"] ] ];
L2 = [1, [2, 3] ];
echo(L1+L1); // ECHO: [2, [4, [6, undef]]]
echo(L1+L2); // ECHO: [2, [4, undef]]
```

Using `+` or `-` with vector operands of different sizes produces a result vector that is the size of the smaller vector.

## Vector Dot-Product Operator

If both operands of multiplication are simple vectors, the result is a number according to the linear algebra rule for dot product. `c = u*v;` results in c = sum(u_i * v_i). If the operands' sizes don't match, the result is `undef`.

## Matrix Multiplication

If one or both operands of multiplication are matrices, the result is a simple vector or matrix according to the linear algebra rules for matrix product. In the following, A, B, C... are matrices, u, v, w... are vectors. Subscripts i, j denote element indices.

**Matrix times Matrix:**

For A a matrix of size n x m and B a matrix of size m x p, their product `C = A*B;` is a matrix of size n x p with elements:

C_ij = sum(k=0 to m-1) A_ik * B_kj

`C = B*A;` results in `undef` unless n = p.

**Matrix times Vector:**

For A a matrix of size n x m and v a vector of size m, their product `u = A*v;` is a vector of size n with elements:

u_i = sum(k=0 to m-1) A_ik * v_k

In linear algebra, this is the product of a matrix and a column vector.

**Vector times Matrix:**

For v a vector of size n and A a matrix of size n x m, their product `u = v*A;` is a vector of size m with elements:

u_j = sum(k=0 to n-1) v_k * A_kj

In linear algebra, this is the product of a row vector and a matrix.

**Note:** Matrix multiplication is not commutative: AB != BA, Av != vA.
