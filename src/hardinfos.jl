# 内存条信息
function draminfo()
    info = read(`wmic memorychip get Manufacturer,SerialNumber,Capacity /value`, String)
    return replace(info, '\r'=>"", '\n'=>"|", " "=>"")
end

# CPU 信息
function cpuinfo()
    info = read(`wmic cpu get Name,SystemName,ProcessorId,SerialNumber /value`, String)
    return replace(info, '\r'=>"", '\n'=>"|", " "=>"")
end

# 硬盘信息
function diskinfo()
    info = read(`wmic diskdrive where "InterfaceType<>'USB'" get Model,SerialNumber,Partitions,Signature,Size /value`, String)
    return replace(info, '\r'=>"", '\n'=>"|", " "=>"")
end

# 主板信息
function baseboardinfo()
    info = read(`wmic baseboard get Manufacturer,Product,SerialNumber,Version /value`, String)
    return replace(info, '\r'=>"", '\n'=>"|", " "=>"")
end

# 网卡信息
function macinfo()
    info = read(`wmic nic where "PhysicalAdapter='True' AND (Name like '%Ethernet%' OR Name like '%Wireless%' OR Name like '%PCIe%')" get MACAddress,Name /value`, String)
    return replace(info, '\r'=>"", '\n'=>"|", " "=>"")
end

# 显卡信息
function gpuinfo()
    info = read(`wmic path win32_videocontroller get  Name /value`, String)
    return replace(info, '\r'=>"", '\n'=>"|", " "=>"")
end

# bios 信息
function biosinfo()
    info = read(`wmic bios get Manufacturer,SerialNumber,Version,CurrentLanguage /value`, String)
    return replace(info, '\r'=>"", '\n'=>"|", " "=>"")
end


function fingerprint()
    dict = Dict{String, String}()
    push!(dict, "dram" => draminfo())
    push!(dict, "cpu" => cpuinfo())
    push!(dict, "disk" => diskinfo())
    push!(dict, "baseboard" => baseboardinfo())
    push!(dict, "mac" => macinfo())
    push!(dict, "gpu" => gpuinfo())
    push!(dict, "bios" => biosinfo())
    return dict
end



function save2jl(dst::String)
    path, name = splitdir(dst)
    if !occursin(".jl", name)
        error("not a .jl file")
    end
    !ispath(path) && mkpath(path)

    fpinfos = fingerprint()
    encoded = Dict{Vector{UInt8}, Vector{UInt8}}()
    for (k,v) ∈ fpinfos
        encoded[UInt8.(transcode(UInt8, k))] = UInt8.(transcode(UInt8, v))
    end

    body = "baseinfo = Dict{Vector{UInt8},Vector{UInt8}}(\n"
    for (k,v) in encoded
        body *= "\t$k => $v,\n"
    end
    body *= ")\n\n"

    open(dst, "w") do io
        write(io, body)
    end
    return nothing
end

