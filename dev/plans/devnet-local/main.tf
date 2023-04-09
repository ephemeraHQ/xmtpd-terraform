module "cluster" {
  source = "../../../modules/xmtp-cluster-kind"

  name                 = "xmtp-devnet"
  node_container_image = "xmtp/xmtpd:latest"
  enable_chat_app      = false
  enable_monitoring    = false
  ingress_http_port    = 8080
  ingress_https_port   = 8443

  nodes = [
    {
      "name" : "node1",
      "node_id" : "12D3KooWQTBzH9ow24ALRi5YEhp2htn2ss7XV1es98hbq5enCjUb",
      "p2p_public_address" : "/dns4/node1/tcp/9000/p2p/12D3KooWQTBzH9ow24ALRi5YEhp2htn2ss7XV1es98hbq5enCjUb",
      "p2p_persistent_peers" : [
        "/dns4/node2/tcp/9000/p2p/12D3KooWFfse73aHJGBkZpUVymoozyMXKmBH7f4Y6kKcp4rviTyY",
        "/dns4/node3/tcp/9000/p2p/12D3KooWQcjJL43hPyGHGQx3RCrQC2HLxVyvMUH8GoAL2pqR7wZv"
      ],
      "store_type" : "postgres"
    },
    {
      "name" : "node2",
      "node_id" : "12D3KooWFfse73aHJGBkZpUVymoozyMXKmBH7f4Y6kKcp4rviTyY",
      "p2p_public_address" : "/dns4/node2/tcp/9000/p2p/12D3KooWFfse73aHJGBkZpUVymoozyMXKmBH7f4Y6kKcp4rviTyY",
      "p2p_persistent_peers" : [
        "/dns4/node1/tcp/9000/p2p/12D3KooWQTBzH9ow24ALRi5YEhp2htn2ss7XV1es98hbq5enCjUb",
        "/dns4/node3/tcp/9000/p2p/12D3KooWQcjJL43hPyGHGQx3RCrQC2HLxVyvMUH8GoAL2pqR7wZv"
      ],
      "store_type" : "bolt"
    },
    {
      "name" : "node3",
      "node_id" : "12D3KooWQcjJL43hPyGHGQx3RCrQC2HLxVyvMUH8GoAL2pqR7wZv",
      "p2p_public_address" : "/dns4/node3/tcp/9000/p2p/12D3KooWQcjJL43hPyGHGQx3RCrQC2HLxVyvMUH8GoAL2pqR7wZv",
      "p2p_persistent_peers" : [
        "/dns4/node1/tcp/9000/p2p/12D3KooWQTBzH9ow24ALRi5YEhp2htn2ss7XV1es98hbq5enCjUb",
        "/dns4/node2/tcp/9000/p2p/12D3KooWFfse73aHJGBkZpUVymoozyMXKmBH7f4Y6kKcp4rviTyY"
      ]
    }
  ]

  // These would normally be secret variables marked as "sensitive", but this is for local dev and demonstration.
  node_keys = {
    node1 = "08011240697d353ba6f2b4e26c168db61654a256c0675110b1627b77508f36882982c8b1d9729889bc3c8400bf0cda9661678042576e1bd22dd2ed7b82c737bd958518d0"
    node2 = "0801124035d3207f38a51a964844a090d4efb1419355ee6e27ffd7f5c14f08b27e2c71ce56f937d399054382f5df596d3596d7f8a97535539d9d435ea54cb8e69203860f"
    node3 = "080112408c6492d49a543e8b72947066a6cd209bb72750420d02ebd5729df503309e8a38dbe43a11679070432033b2dd27dc09b297ace646689dd5501cebcc81925cdebd"
  }
}
