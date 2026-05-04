extension ChatResponseExtensions on ChatResponse {
  bool containsImageWithSupportedFormat() {
    return response.messages.containsImageWithSupportedFormat();
  }
}
