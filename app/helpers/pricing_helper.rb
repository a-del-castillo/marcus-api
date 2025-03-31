module PricingHelper
    
    def calculate_part_price(part_id, parts_list = [])
        part = Part.find_by(id: part_id)
        if part
            part.pricemodifiers.each do |pricemod|
                if parts_list.include?(pricemod.variator_part.id)
                    return pricemod.price.to_f.round(2)
                end
            end
            return part.price.to_f.round(2)
        end
        return 0
    end

    # Calcula el precio total de un order (suma de todos los parts)
    def calculate_order_total(order)
        total = 0.0
        order.parts.each do |part|
        total += calculate_part_price(part)
        end
        total
    end

    def calculate_config_price(config_parts)
        price = 0
        config_parts.each do |part_id|
            price += calculate_part_price(part_id, config_parts)
        end
        return price.to_f.round(2)
    end
end