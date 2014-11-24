
module Net
  module TNS
    module Version
      VERSION_9I = 312
      VERSION_10G = 313
      VERSION_11G = 314
      # Other important versions include:
      # 308 - The last version before some significant changes to TNS, particularly noticeable in Connect packets
      # 300 - Many Oracle clients send this as their minimum version

      ALL_VERSIONS = [ VERSION_9I, VERSION_10G, VERSION_11G ]
    end
  end
end
