defmodule CustomerFeedback.UtilsTest do
  use CustomerFeedback.DataCase

  alias CustomerFeedback.Utils

  describe "#prefix_mandatory_char" do
    test "Prefix string if character is absent in the beginning" do
      assert "/url/path" = Utils.prefix_mandatory_char("url/path", "/")
      assert "abbbbb" = Utils.prefix_mandatory_char("bbbbb", "a")
    end

    test "Does not prefix string if character is present in the beginning" do
      assert "/url/path" = Utils.prefix_mandatory_char("/url/path", "/")
      assert "abbbbb" = Utils.prefix_mandatory_char("abbbbb", "a")
    end

    test "Raise error if second argument is not one character long" do
      assert_raise ArgumentError, fn ->
        Utils.prefix_mandatory_char("/url/path", "//")
      end
    end

    test "Raise error if first argument is empty string" do
      assert_raise ArgumentError, fn ->
        Utils.prefix_mandatory_char("", "/")
      end
    end
  end
end
