# frozen_string_literal: true

task kill_postgres_connections: :environment do
  db_name = 'ninetyfour_development'
  sh = <<~PSKILL
    ps xa \
      | grep postgres: \
      | grep #{db_name} \
      | grep -v grep \
      | awk '{print $1}' \
      | xargs kill
  PSKILL
  puts `#{sh}`
end

task 'db:drop' => :kill_postgres_connections
