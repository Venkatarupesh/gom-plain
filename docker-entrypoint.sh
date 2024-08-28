#!/bin/sh
#EDITOR="mate --wait" bin/rails credentials:edit
bundle exec puma -C config/puma.rb
#foreman start

#bundle exec sidekiq start
