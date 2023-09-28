# https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.19/#objectmeta-v1-meta
#
# @param annotations
#   Annotations is an unstructured key value map stored with a resource that
#   may be set by external tools to store and retrieve arbitrary metadata.
#
type Kubeinstall::Metadata = Struct[{
    annotations => Optional[Hash[Kubeinstall::Label, String]],
    labels      => Optional[
      Hash[
        Kubeinstall::Label,
        Variant[Enum[''], Kubeinstall::DNSLabel]
      ]
    ],
    namespace   => Optional[Kubeinstall::DNSLabel],
}]
