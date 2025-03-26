# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Part.create([
    {
        name: "Full-suspension",
        category: "frame",
        price: "130",
        available: true,
        extra_props: {}
    },
    {
        name: "Diamond",
        category: "frame",
        price: "50",
        available: true,
        extra_props: {}
    },
    {
        name: "Step through",
        category: "frame",
        price: "80",
        available: true,
        extra_props: {}
    },
    {
        name: "Matte",
        category: "frame finish",
        price: "",
        available: true,
        extra_props: {}
    },
    {
        name: "Shiny",
        category: "frame finish",
        price: "",
        available: true,
        extra_props: {}
    },
    {
        name: "Road wheels",
        category: "wheels",
        price: "80",
        available: true,
        extra_props: {}
    },
    {
        name: "Mountain wheels",
        category: "wheels",
        price: "90",
        available: true,
        extra_props: {}
    },
    {
        name: "Fat bike wheels",
        category: "wheels",
        price: "120",
        available: true,
        extra_props: {}
    },
    {
        name: "Red",
        category: "rim color",
        color: "10",
        price: "",
        available: true,
        extra_props: {}
    },
    {
        name: "Black",
        category: "rim color",
        price: "12",
        available: true,
        extra_props: {}
    },
    {
        name: "Blue",
        category: "rim color",
        price: "13",
        available: true,
        extra_props: {}
    },
    {
        name: "Single-speed chain",
        category: "chain",
        price: "43",
        available: true,
        extra_props: {}
    },
    {
        name: "8-speed chain",
        category: "chain",
        price: "55",
        available: true,
        extra_props: {}
    }
])
