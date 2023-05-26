type Kubeinstall::TopoLVMDeviceClass = Struct[{
    name            => Kubeinstall::Name,
    volumeGroup     => String,
    spareGB         => Optional[Integer],
    isDefault       => Optional[Boolean],
    stripe          => Optional[Integer],
    stripeSize      => Optional[Pattern[/^[1-9][0-9]*[KMGTPEBSkmgtpebs]?$/]],
    lvCreateOptions => Optional[Array[String]],
    type            => Optional[Enum['thick', 'thin']],
    thinPool        => Optional[
      Struct[{
          name               => String,
          overprovisionRatio => Float[1.0],
      }]
    ],
}]
