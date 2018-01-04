SparkleFormation.new(:redshift, provider: :aws).load(:base).overrides do
  resources(:redshift_cluster) do
    type "AWS::Redshift::Cluster"
    depends_on!(:attach_gateway)
    properties do
      cluster_type "single-node"
      node_type "dc1.large"
      dB_name "mndtest"
      master_username "defaultuser"
      master_user_password "foobarFoobar1"
      cluster_parameter_group_name ref!(:redshift_cluster_parameter_group)
      vpc_security_group_ids do
        ref!(:security_group)
      end
      cluster_subnet_group_name ref!(:redshift_cluster_subnetGroup)
      publicly_accessible "true"
      port "5439"
    end
  end

  resources(:redshift_cluster_parameter_group) do
    type "AWS::Redshift::ClusterParameterGroup"
    properties do
      description "cluster parameter group"
      parameter_group_family "redshift-1.0"
      parameters _array(
        -> {
          parameter_name "enable_user_activity_logging"
          parameter_value "true"
        }
      )
    end
  end

  resources(:redshift_cluster_subnet_group) do
    type "AWS::Redshift::ClusterSubnetGroup"
    properties do
      description "redshift cluster subnet group"
      subnet_ids _array(ref!(:public_subnet))
    end
  end

  resources(:vpc) do
    type "AWS::EC2::VPC"
    properties do
      cidr_block "192.168.0.0/24"
      enable_dns_support "false"
      enable_dns_hostnames "false"
      instance_tenancy "default"
      tags _array(
        -> {
          key "Name"
          value "mnd-development"
        }
      )
    end
  end

  resources(:public_subnet) do
    type "AWS::EC2::Subnet"
    properties do
      cidr_block "192.168.0.192/27"
      vpc_id ref!(:vpc)
    end
  end

  resources(:security_group) do
    type "AWS::EC2::SecurityGroup"
    properties do
      group_description "redshift security group"
      security_group_ingress _array(
        -> {
          cidr_ip "0.0.0.0/0"
          from_port "5439"
          to_port "5439"
          ip_protocol "tcp"
        }
      )
      vpc_id ref!(:vpc)
    end
  end

  resources(:internet_gateway) do
    type "AWS::EC2::InternetGateway"
  end

  resources(:attach_gateway) do
    type "AWS::EC2::VPCGatewayAttachment"
    properties do
      vpc_id ref!(:vpc)
      internet_gateway_id ref!(:internet_gateway)
    end
  end
end
