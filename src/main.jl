include("./wfc.jl")
using .MapGenerator

function input_setup()
    print("⛬ Input image width: ")
    width = parse(UInt32, readline())

    print("⛬ Input image height: ")
    height = parse(UInt32, readline())

    print("⛬ Input filepath: ")
    filepath = strip(readline())

    return (width, height), filepath
end

function main()
    printstyled("⛬ Welcome to the Wave Function Collapse Map Generator!\n"; color = :green)
    SIZE, FILEPATH = input_setup()
    MapGenerator.generate_image(SIZE, FILEPATH)
    printstyled("⛬ Finished\n"; color = :green)
end

main()