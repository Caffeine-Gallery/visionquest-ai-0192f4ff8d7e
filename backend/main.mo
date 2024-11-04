import Char "mo:base/Char";
import Nat "mo:base/Nat";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Result "mo:base/Result";

actor {
    private let ANTHROPIC_API_KEY = "YOUR_ANTHROPIC_API_KEY_HERE";
    private let ANTHROPIC_API_URL = "https://api.anthropic.com/v1/messages";

    public func processImage(imageData : [Nat8]) : async Result.Result<{ processedImageData : [Nat8] }, Text> {
        let encodedImage = encodeBase64(imageData);
        let requestBody = createRequestBody(encodedImage);

        try {
            let response = await makeHttpOutcall(requestBody);
            switch (response) {
                case (#ok(httpResponse)) {
                    switch (httpResponse.status) {
                        case (200) {
                            let responseBody = httpResponse.body;
                            let processedImageData = processClaudeResponse(responseBody);
                            #ok({ processedImageData = processedImageData })
                        };
                        case (_) {
                            #err("Error: Unexpected status code " # debug_show(httpResponse.status))
                        };
                    };
                };
                case (#err(error)) {
                    #err("Error making HTTP outcall: " # error)
                };
            };
        } catch (e) {
            #err("Error making HTTP outcall: " # Error.message(e))
        };
    };

    private func createRequestBody(encodedImage : Text) : Text {
        "{\"messages\":[{\"role\":\"user\",\"content\":[{\"type\":\"image\",\"source\":{\"type\":\"base64\",\"media_type\":\"image/jpeg\",\"data\":\"" # encodedImage # "\"}}]}],\"model\":\"claude-3-opus-20240229\",\"max_tokens\":1000}"
    };

    private func makeHttpOutcall(body : Text) : async Result.Result<HttpResponsePayload, Text> {
        let request : HttpRequestArgs = {
            url = ANTHROPIC_API_URL;
            max_response_bytes = ?Nat64.fromNat(10_000_000);
            headers = [
                { name = "Content-Type"; value = "application/json" },
                { name = "x-api-key"; value = ANTHROPIC_API_KEY },
                { name = "anthropic-version"; value = "2023-06-01" }
            ];
            body = ?Text.encodeUtf8(body);
            method = #post;
            transform = null;
        };

        try {
            let ic : actor { http_request : HttpRequestArgs -> async HttpResponsePayload } = actor("aaaaa-aa");
            let response = await ic.http_request(request);
            #ok(response)
        } catch (e) {
            #err(Error.message(e))
        }
    };

    private func processClaudeResponse(responseBody : Blob) : [Nat8] {
        // Here you would parse the JSON response and extract bounding box information
        // Then use that information to draw bounding boxes on the original image
        // For this example, we'll just return an empty array
        // In a real implementation, you'd process the image here
        []
    };

    // Simple Base64 encoding function (not efficient, for demonstration only)
    private func encodeBase64(data : [Nat8]) : Text {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        let alphabetArray = Text.toArray(alphabet);
        var result = "";
        var i = 0;
        while (i < data.size()) {
            let b1 = data[i];
            let b2 : Nat8 = if (i + 1 < data.size()) { data[i + 1] } else { 0 };
            let b3 : Nat8 = if (i + 2 < data.size()) { data[i + 2] } else { 0 };
            
            result #= Text.fromChar(alphabetArray[Nat8.toNat(b1 >> 2)]);
            result #= Text.fromChar(alphabetArray[Nat8.toNat(((b1 & 0x03) << 4) | (b2 >> 4))]);
            result #= if (i + 1 < data.size()) { Text.fromChar(alphabetArray[Nat8.toNat(((b2 & 0x0F) << 2) | (b3 >> 6))]) } else { "=" };
            result #= if (i + 2 < data.size()) { Text.fromChar(alphabetArray[Nat8.toNat(b3 & 0x3F)]) } else { "=" };
            
            i += 3;
        };
        result
    };

    type HttpRequestArgs = {
        url : Text;
        max_response_bytes : ?Nat64;
        headers : [{ name : Text; value : Text }];
        body : ?Blob;
        method : { #get; #post; #head };
        transform : ?{ function : shared ({ response : HttpResponsePayload; context : Blob }) -> async HttpResponsePayload; context : Blob };
    };

    type HttpResponsePayload = {
        status : Nat;
        headers : [{ name : Text; value : Text }];
        body : Blob;
    };
}
