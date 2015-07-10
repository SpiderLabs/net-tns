## TNS Connection Sequence (<= 9i)
C: TNS Connect
S: TNS Accept
C: TNS Data [ANO Negotiation Request]
C: TNS Data [ANO Negotiation Response]

## TNS Connection Sequence (> 9i)
C: TNS Connect
S: TNS Resend
C: TNS Connect
S: TNS Accept
C: TNS Data [ANO Negotiation Request]
C: TNS Data [ANO Negotiation Response]

## TTI Connection Sequence
[TNS connection first]
[All TTI messages are passed via TNS Data packets]
C: TTI Protocol Negotiation Request
S: TTI Protocol Negotiation Response
C: TTI Data Type Neogitation Request
S: TTI Data Type Neogitation Response

## Authentication Sequence
[TTI connection first]
[All TTI messages are passed via TNS Data packets]
C: TTI Function Call [Pre-Authentication Request]
S: TTI OK [Pre-Authentication Response]
C: TTI Function Call [Authentication Request]
S: TTI OK [Authentication Response]
