# encoding: utf-8

RSpec.describe TTY::File, '#prepend_to_file' do
  it "appends to file" do
    file = tmp_path('Gemfile')
    result = TTY::File.prepend_to_file(file, "gem 'tty'\n", verbose: false)
    expect(result).to eq(true)
    expect(File.read(file)).to eq([
      "gem 'tty'\n",
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "prepends multiple lines to file" do
    file = tmp_path('Gemfile')
    TTY::File.prepend_to_file(file, "gem 'tty'\n", "gem 'rake'\n", verbose: false)
    expect(File.read(file)).to eq([
      "gem 'tty'\n",
      "gem 'rake'\n",
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "prepends content in a block" do
    file = tmp_path('Gemfile')
    TTY::File.prepend_to_file(file, verbose: false) { "gem 'tty'\n"}
    expect(File.read(file)).to eq([
      "gem 'tty'\n",
      "gem 'nokogiri'\n",
      "gem 'rails', '5.0.0'\n",
      "gem 'rack', '>=1.0'\n",
    ].join)
  end

  it "logs action" do
    file = tmp_path('Gemfile')
    expect {
      TTY::File.prepend_to_file(file, "gem 'tty'")
    }.to output(/\e\[32mprepend\e\[0m.*Gemfile/).to_stdout_from_any_process
  end

  it "logs action without color" do
    file = tmp_path('Gemfile')
    expect {
      TTY::File.prepend_to_file(file, "gem 'tty'", color: false)
    }.to output(/\s+prepend.*Gemfile/).to_stdout_from_any_process
  end
end
