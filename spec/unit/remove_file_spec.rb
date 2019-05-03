# frozen_string_literal: true

RSpec.shared_context '#remove_file' do
  it "removes a given file", unless: RSpec::Support::OS.windows? do
    src_path = path_factory.call('Gemfile')

    TTY::File.remove_file(src_path, verbose: false)

    expect(::File.exist?(src_path)).to be(false)
  end

  it "removes a directory" do
    src_path = path_factory.call('templates')

    TTY::File.remove_file(src_path, verbose: false)

    expect(::File.exist?(src_path)).to be(false)
  end

  it "pretends removing file" do
    src_path = path_factory.call('Gemfile')

    TTY::File.remove_file(src_path, noop: true, verbose: false)

    expect(::File.exist?(src_path)).to be(true)
  end

  it "removes files in secure mode" do
    src_path = path_factory.call('Gemfile')
    allow(::FileUtils).to receive(:rm_r)

    TTY::File.remove_file(src_path, verbose: false, secure: false)

    expect(::FileUtils).to have_received(:rm_r).
      with(src_path.to_s, force: nil, secure: false)
  end

  it "logs status" do
    src_path = path_factory.call('Gemfile')

    expect {
      TTY::File.remove_file(src_path, noop: true)
    }.to output(/\e\[31mremove\e\[0m(.*)Gemfile/).to_stdout_from_any_process
  end

  it "logs status without color" do
    src_path = path_factory.call('Gemfile')

    expect {
      TTY::File.remove_file(src_path, noop: true, color: false)
    }.to output(/\s+remove(.*)Gemfile/).to_stdout_from_any_process
  end
end

module TTY::File
  RSpec.describe "#remove_file" do
    context "when passed a String instance for the file argument" do
      let(:path_factory) { method(:tmp_path) }

      it_behaves_like "#remove_file"
    end

    context "when passed a Pathname instance for the file argument" do
      let(:path_factory) { method(:tmp_pathname) }

      it_behaves_like "#remove_file"
    end
  end
end
