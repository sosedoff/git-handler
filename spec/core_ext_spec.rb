require 'spec_helper'

describe Array do
  it { should respond_to :include_all? }
  it { should respond_to :include_any? }

  it 'should include all elements' do
    [1,2,3].include_all?([1,2,3]).should be_true
    [1,2,3].include_all?([1,2]).should be_true
    [1,2].include_all?([1,2,3]).should be_false
    [1,2].include_all?([4,5,6]).should be_false
    [].include_all?([4,5,6]).should be_false
    [].include_all?([]).should be_true
  end

  it 'should include any elements' do
    [1,2,3].include_any?([1,2,3]).should be_true
    [1,2,3].include_any?([1,2]).should be_true
    [1,2,3].include_any?([1,4,5]).should be_true
    [1,2,3].include_any?([4,5,6]).should be_false
    [].include_any?([]).should be_false
  end
end

describe Hash do
  it { should respond_to :include_all? }
  it { should respond_to :include_any? }

  it 'should include all keys' do
    ({'a' => 1, 'b' => 2, 'c' => 3}.include_all?(['a','b','c'])).should be_true
    ({'a' => 1, 'b' => 2, 'c' => 3}.include_all?(['a','b'])).should be_true
    ({'a' => 1, :b => 2}).include_all?(['a', 'b']).should be_false
    ({'a' => 1, 'b' => 2}.include_all?(['c'])).should be_false
  end

  it 'should include any keys' do
    ({'a' => 1, 'b' => 2}.include_any?(['a', 'b', 'c'])).should be_true
    ({'a' => 1, :b => 2}.include_any?(['a', 'b', 'c'])).should be_true
    ({'a' => 1, 'b' => 2}.include_any?([:a, :b])).should be_false
    ({'a' => 1, 'b' => 2}.include_any?(['d', 'e'])).should be_false
  end
end