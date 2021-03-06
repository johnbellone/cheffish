require 'support/spec_support'

describe Cheffish do
  let(:directory_that_exists) {
    Dir.mktmpdir("cheffish-rspec")
  }

  let(:directory_that_does_not_exist) {
    dir = Dir.mktmpdir("cheffish-rspec")
    FileUtils.remove_entry dir
    dir
  }

  let(:private_key_contents) { "contents of private key" }

  let(:private_key_pem_contents) { "contents of private key pem" }

  let(:private_key_garbage_contents) { "da vinci virus" }

  def setup_key
    key_file = File.expand_path("ned_stark", directory_that_exists)
    File.open(key_file, "w+") do |f|
      f.write private_key_contents
    end
  end

  def setup_pem_key
    key_file = File.expand_path("ned_stark.pem", directory_that_exists)
    File.open(key_file, "w+") do |f|
      f.write private_key_pem_contents
    end
  end

  def setup_garbage_key
    key_file = File.expand_path("ned_stark.pem.bak", directory_that_exists)
    File.open(key_file, "w+") do |f|
      f.write private_key_garbage_contents
    end
  end

  shared_examples_for "returning the contents of the key file if it finds one" do
    it "returns nil if it cannot find the private key file" do
      expect(Cheffish.get_private_key("ned_stark", config)).to be_nil
    end

    it "returns the contents of the key if it doesn't have an extension" do
      setup_key
      expect(Cheffish.get_private_key("ned_stark", config)).to eq(private_key_contents)
    end

    it "returns the contents of the key if it has an extension" do
      setup_pem_key
      expect(Cheffish.get_private_key("ned_stark", config)).to eq(private_key_pem_contents)
    end

    # we arbitrarily prefer "ned_stark" over "ned_stark.pem" for deterministic behavior
    it "returns the contents of the key that does not have an extension if both exist" do
      setup_key
      setup_pem_key
      expect(Cheffish.get_private_key("ned_stark", config)).to eq(private_key_contents)
    end
  end

  context "#get_private_key" do
    context "when private_key_paths has a directory which is empty" do
      let(:config) {
        { :private_key_paths => [ directory_that_exists ] }
      }

      it_behaves_like "returning the contents of the key file if it finds one"

      context "when it also has a garbage file" do
        before { setup_garbage_key }

        it "does not return the da vinci virus if we find only the garbage file" do
          setup_garbage_key
          expect(Cheffish.get_private_key("ned_stark", config)).to be_nil
        end

        it_behaves_like "returning the contents of the key file if it finds one"
      end

    end

    context "when private_key_paths leads with a directory that does not exist and then an empty directory" do
      let(:config) {
        { :private_key_paths => [ directory_that_does_not_exist, directory_that_exists ] }
      }

      it_behaves_like "returning the contents of the key file if it finds one"
    end
  end
end
