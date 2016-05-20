Edukator
================

This application was generated with the [rails_apps_composer](https://github.com/RailsApps/rails_apps_composer) gem
provided by the [RailsApps Project](http://railsapps.github.io/).

Rails Composer is supported by developers who purchase our RailsApps tutorials.

Problems? Issues?
-----------

Need help? Ask on Stack Overflow with the tag 'railsapps.'

Your application contains diagnostics in the README file. Please provide a copy of the README file when reporting any issues.

If the application doesn't work as expected, please [report an issue](https://github.com/RailsApps/rails_apps_composer/issues)
and include the diagnostics.

Ruby on Rails
-------------

This application requires:

- Ruby 2.2.1
- Rails 4.2.5

Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).

Dev setup (Mac OSX)
-------------------

##### Use RVM to manage Ruby environment  
It is recommended not to use OSX System installed Ruby but instead use RVM based Ruby environment within $HOME directory. This doesn't require 'sudo' access, doesn't mess up the OS level folders, makes it easy to wipe everything clean and do a fresh install.

Helpful link to use RVM: http://usabilityetc.com/articles/ruby-on-mac-os-x-with-rvm/

`brew install gnupg`  
`gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3`  
`curl -sSL https://get.rvm.io | bash -s stable --ruby  #installs rvm and latest ruby`  
`source "$HOME/.rvm/scripts/rvm"  `  

Exit and reopen the terminal to apply new ENV changes

##### Install Postgresql database  
Helpful link: http://exponential.io/blog/2015/02/21/install-postgresql-on-mac-os-x-via-brew/  
`brew install postgresql`  
`createdb ``` `whoami` ``  
`/usr/local/Cellar/postgresql/9.5.1/bin/createuser -s postgres`  
You can access PostgreSQL interactive terminal using `psql` and inside the terminal you can run `\du` to list roles and `\l` to list databases and `\?` to view help.  

##### Install project dependecnies
All dependent modules are specified in the Gemfile at the root of the project. We need `bundler` to install the dependencies.  
`gem install bundler`  
`bundle install #installs stuff in Gemfile`  

##### Setup database  
`rake db:setup`  

Verify that the database is setup properly by opening `psql`  
`\l #list databases`  
`\c edukator_development # connect to newly created databases`  
`\d #to list tables`  

##### Start the server  
`rails s`  
If all goes well, you should now be able to access http://localhost:3000. You can login with `admin_email` and `admin_password` mentioned inside `config/secrets.yml`.  

Getting Started
---------------

Documentation and Support
-------------------------

Issues
-------------

Similar Projects
----------------

Contributing
------------

Credits
-------

License
-------
