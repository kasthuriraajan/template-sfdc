// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

# Represents message resource which will be received as a response from the Gmail API.
#
# + threadId - Thread ID which the message belongs to
# + id - Message Id
# + labelIds - The label ids of the message
# + raw - Represent the entire message in base64 encoded string
# + snippet - Short part of the message text
# + historyId - The id of the last history record that modified the message
# + internalDate - The internal message creation timestamp(epoch ms)
# + sizeEstimate - Estimated size of the message in bytes
# + headers - The map of headers in the top level message part representing the entire message payload in a
#   standard RFC 2822 message. The key of the map is the header name and the value is the header value.
# + headerTo - Email header **To**
# + headerFrom - Email header **From**
# + headerBcc - Email header **Bcc**
# + headerCc - Email header **Cc**
# + headerSubject - Email header **Subject**
# + headerDate - Email header **Date**
# + headerContentType - Email header **ContentType**
# + mimeType - MIME type of the top level message part
# + plainTextBodyPart - MIME Message Part with text/plain content type
# + htmlBodyPart - MIME Message Part with text/html content type
# + inlineImgParts - MIME Message Parts with inline images with the image/* content type
# + msgAttachments - MIME Message Parts of the message consisting the attachments
# 
# 
public type Message record {
    string threadId = "";
    string id = "";
    string[] labelIds = [];
    string raw = "";
    string snippet = "";
    string historyId = "";
    string internalDate = "";
    string sizeEstimate = "";
    map<string> headers = {};
    string headerTo = "";
    string headerFrom = "";
    string headerBcc = "";
    string headerCc = "";
    string headerSubject = "";
    string headerDate = "";
    string headerContentType = "";
    string mimeType = "";
    MessageBodyPart plainTextBodyPart = {};
    MessageBodyPart htmlBodyPart = {};
    MessageBodyPart[] inlineImgParts = [];
    MessageBodyPart[] msgAttachments = [];
};

# Represents the email message body part of a message resource response.
#
# + body - The body data of the message part. This is a base64 encoded string
# + mimeType - MIME type of the message part
# + bodyHeaders - Headers of the MIME Message Part
# + fileId - The file id of the attachment/inline image in message part *(This is empty unless the message part
#            represent an inline image/attachment)*
# + fileName - The file name of the attachment/inline image in message part *(This is empty unless the message part
#            represent an inline image/attachment)*
# + partId - The part id of the message part
# + size - Number of bytes of message part data
public type MessageBodyPart record {
    string body = "";
    string mimeType = "";
    map<string> bodyHeaders = {};
    string fileId = "";
    string fileName = "";
    string partId = "";
    string size = "";
};