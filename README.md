# README

* Ruby version 3.2.3

* Database setup

  rails db:create
  
  rails db:migrate
  
  rails db:seed

* How to run the test suite

  bundle exec rspec

## Data model
### Main entities:
#### User

-Attributes: id, role ('admin' / 'user')

-Relations:

Has multiple Config (bike configurations)

Has multiple Order


#### Part

- Attributes: id, name, category, price, available, quantity
- Relations:

Belongs to multiple Config through a N:M relation

Belongs to multiple Order through OrderArticle


#### Config

- Attributes: id, name, price, user_id
- Relations:

Belongs to a single User

Has multiple Part through a N:M relation

Belongs to multiple Order through OrderArticle


#### Order

- Attributes: id, user_id, status (puede ser 'in cart', etc.), price
- Relations:

Belongs to a single User

Has multiple Part through OrderArticle

Has multiple Config through OrderArticle


#### OrderArticle (join table)

- Attributes: id, order_id, part_id (opcional), config_id (opcional)
- Relations:

Belongs to a single Order

Can belong to one Part or one Config (but not both)


### Relations Diagram 
```
User 1 --- * Config
 |
 |
 * 
Order 1 --- * OrderArticle
              /        \
             /          \
            /            \
Part * --- *              * --- * Config
 |\
 | \
 |  * price_modifiers
 | 
 *
Incompatibilities
```

## Main user actions: 
Users can create custom bike configurations (Config) by selecting multiple parts (Part).

Users can both add independent parts and custom bike configurations to their shopping cart (Order with 'in Cart' status).

When a user completes his shopping, by pressing the pay button in the cart, his order status is updated to 'paid'.

Administrators can see every order, while common users can only access their own.

## Special details
### Price calculation:

The system automatically calculates price of each part of a configuration based on the prices of its parts (some parts have a different price when paired with other parts).

The system automatically calculates price of a configuration based on the prices of its parts.

Total price of an order is calculated by doing the prices sum for both independant parts and custom configurations.

Some parts are incompatible with others and can't be used in the same custom configuration. 

### Autentication:

System uses JWT tokens for user autentication.

Some endpoints are protected and are accesible only for autenticated users.

Some endpoints have aditional restrictions based on user role (ie: only admins can see all the orders).


### Shopping cart:

Each autenticated user have their order with 'in Cart' status stored in the server that gets updated when parts and/or custom configurations are added or removed.

Non autenticated users carts are not stored at all besides current vars tied to UI execution.
Usuars can add, remove or modify articles from their shopping carts.

### Possible improvements (changes I wanted to add but had to leave in the TO-DO list due to time constrains):

Create method in OrdersController does too many things and would benefit from being refactored into smaller and more specific methods.

Configs in orders need to be improved in order to avoid data duplication on the database.

Parts quantity is not completely implemented at order level.

Data validation can be greatly improved.

