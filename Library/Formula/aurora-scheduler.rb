class AuroraScheduler < Formula
  desc "Apache Aurora Scheduler Client"
  homepage "https://aurora.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=aurora/0.9.0/apache-aurora-0.9.0.tar.gz"
  sha256 "16040866f3a799226452b1541892eb80ed3c61f47c33f1ccb0687fb5cf82767c"

  depends_on "gradle" => :build
  depends_on "mesos"
  depends_on :java => "1.8+"

  def pour_bottle?
    quiet_system("/usr/libexec/java_home --version 1.8 --failfast")
  end

  def install
    remove_file("buildSrc/build.gradle", true)
    touch("buildSrc/build.gradle")
    system "gradle", "wrapper"
    system "./gradlew", "installDist"
    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["CFLAGS"] = "-Qunused-arguments"
    ENV["CPPFLAGS"] = "-Qunused-arguments"
    system "./pants", "binary", "src/main/python/apache/aurora/client/cli:kaurora"
    system "./pants", "binary", "src/main/python/apache/aurora/admin:kaurora_admin"
    system "./pants", "binary", "src/main/python/apache/aurora/tools:thermos"
    system "./pants", "binary", "src/main/python/apache/aurora/tools:thermos_observer"
    system "./pants", "binary", "src/main/python/apache/thermos/bin:thermos_runner"
    system "./build-support/release/make-python-sdists"
    bin.install "dist/kaurora.pex" => "aurora"
    bin.install "dist/kaurora_admin.pex" => "aurora_admin"
    bin.install "dist/thermos_runner.pex" => "thermos_runner"
    bin.install "dist/thermos_observer.pex" => "thermos_observer"
  end

  test do
    mkdir_p("~/.aurora/")
    touch("~/.aurora/clusters.json")
    File.open("~/.aurora/clusters.json", "w") { f.write("[{ \"name\": \"devcluster\", \"slave_root\": \"/tmp/mesos/\", \"zk\": \"127.0.0.1\", \"scheduler_zk_path\": \"/aurora/scheduler\", \"auth_mechanism\": \"UNAUTHENTICATED\" }]") }
    system "#{bin}/aurora_admin", "get_cluster_config", "devcluster"
  end
end
