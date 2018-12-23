desc "get posts by month"
task :get_posts, [:number_of_month] => :environment do |t, args|
  require "task_helpers/posts_processor"
  PostsProcessor.new(number_of_month: args.number_of_month).process
end