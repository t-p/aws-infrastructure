SparkleFormation.new(:compute, provider: :aws).load(:base).overrides do
  dynamic!(:node, :sparkle)
end
