# https://godoc.org/k8s.io/apimachinery/pkg/api/resource#Quantity
#
# <quantity> ::= <signedNumber><suffix> (Note that <suffix> may be empty, from the "" case in <decimalSI>.)
# <digit> ::= 0 \| 1 \| …​ \| 9
# <digits> ::= <digit> \| <digit><digits>
# <number> ::= <digits> \| <digits>.<digits> \| <digits>. \| .<digits>
# <sign> ::= "+" \| "-"
# <signedNumber> ::= <number> \| <sign><number>
# <suffix> ::= <binarySI> \| <decimalExponent> \| <decimalSI>
# <binarySI> ::= Ki \| Mi \| Gi \| Ti \| Pi \| Ei (International System of units; See: http://physics.nist.gov/cuu/Units/binary.html)
# <decimalSI> ::= m \| "" \| k \| M \| G \| T \| P \| E (Note that 1024 = 1Ki but 1000 = 1k; I didn't choose the capitalization.)
# <decimalExponent> ::= "e" <signedNumber> \| "E" <signedNumber>
type Kubeinstall::Quantity = Variant[
  Kubeinstall::BinaryQuantity,
  Kubeinstall::DecimalQuantity,
  Kubeinstall::ExponentQuantity
]
