*** Settings ***
Documentation       Template robot main suite.
Library    RPA.Robocorp.Vault
Library    RPA.Nanonets    WITH NAME    Nanonets
Library    RPA.Base64AI    WITH NAME    Base64
Library    helper

*** Variables ***
${filename}    invoice.png

*** Tasks ***
Extract document data
    Extract with nanonets
    Extract with base64ai
    #Extract with awstextract
    #Extract with googledocai

*** Keywords ***
Extract with nanonets
    Log To Console    Using Nanonets
    ${nanonets}=    Get Secret    Nanonets
    Nanonets.Set Authorization    ${nanonets}[api-key]

    ${result}=    Predict File
    ...  ${CURDIR}${/}files${/}${filename}
    ...  ${nanonets}[model]

    ${fields}=    Get Fields From Prediction Result    ${result}
    FOR    ${field}    IN    @{fields}
        Log To Console    Label:${field}[label] Text:${field}[ocr_text]
    END

    ${tables}=    Get Tables From Prediction Result    ${result}
    FOR    ${table}    IN    @{tables}
        FOR    ${rows}    IN    ${table}[rows]
            FOR    ${row}    IN    @{rows}
                ${cells}=    Evaluate    [cell['text'] for cell in $row]
                Log To Console    ROW:${{" | ".join($cells)}}
            END
        END
    END

Extract with base64ai
    Log To Console    Using Base64ai
    ${base64}=   Get Secret  Base64
    Base64.Set Authorization  ${base64}[email]   ${base64}[api-key]

    ${results}=  Scan Document File
    ...   ${CURDIR}${/}files${/}${filename}
    ...   model_types=finance/invoice

    FOR  ${result}  IN  @{results}
        Log To Console  Model: ${result}[model]
        
        ${fields}=    Get Keys Values    ${result}[fields]

        FOR    ${field}    IN    @{fields}
            Log To Console  Field: ${field}[0], ${field}[1]
        END
    END

Extract with awstextract
    Log To Console    Using AWS Textract

    # TODO

Extract with googledocai
    Log To Console    Using Google Doc AI

    # TODO