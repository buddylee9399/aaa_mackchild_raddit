# THINGS IN HERE

## GEMS

```
gem 'bootstrap-sass', '~> 3.4', '>= 3.4.1'
gem 'devise'
gem 'acts_as_votable'
gem 'simple_form'
```
- really only used acts as votable and devise
- devise set for turbo, rails 7
- from: https://dev.to/efocoder/how-to-use-devise-with-turbo-in-rails-7-9n9

## MODELS
- devise user
- user has many links
- links scaffold, with comments on the show page
- links act as votable
- link has many comments, belongs to user
- comment belongs to link and user

## OTHER
- although bootstrap sass installed, it wasn't used for any stylings
- used button_to for the acts as votable links