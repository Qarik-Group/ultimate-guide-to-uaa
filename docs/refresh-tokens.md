# Refresh Tokens

The UAA offers two types of refresh tokens - Opaque and JWT. I think you need to know what they are and why the UAA default is wrong.

## Opaque refresh tokens

Opaque refresh tokens look very different from access tokens. They are a short text string that means nothing to anyone outside of the UAA itself. That is, when the UAA publishes an opaque refresh token it stores all the metadata for the refresh token in its database and the refresh token is a reference.

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6InVhYS1qd3Qta2V5LTEiLCJ0eXAiOiJKV1QifQ.eyJqdGkiOiJjNjQwOWY3MzhhMjc0OTZlYTE3ZjU5NTg1MGNlMjAzMiIsInN1YiI6IjQ4YThkNDY0LTEyZGQtNGIxNC1iN2EwLTk2YWY1ODM3OWZmYiIsInNjb3BlIjpbIm9wZW5pZCIsImFpcnBvcnRzLmFsbCJdLCJjbGllbnRfaWQiOiJhaXJwb3J0cyIsImNpZCI6ImFpcnBvcnRzIiwiYXpwIjoiYWlycG9ydHMiLCJncmFudF90eXBlIjoicGFzc3dvcmQiLCJ1c2VyX2lkIjoiNDhhOGQ0NjQtMTJkZC00YjE0LWI3YTAtOTZhZjU4Mzc5ZmZiIiwib3JpZ2luIjoidWFhIiwidXNlcl9uYW1lIjoiYWlycG9ydHMtYWxsIiwiZW1haWwiOiJhaXJwb3J0cy1hbGxAZXhhbXBsZS5jb20iLCJhdXRoX3RpbWUiOjE1MzA3Mzc3NTUsInJldl9zaWciOiI0YzNiMzgxMCIsImlhdCI6MTUzMDczNzc1NSwiZXhwIjoxNTMwNzgwOTU1LCJpc3MiOiJodHRwczovLzE5Mi4xNjguNTAuNjo4NDQzL29hdXRoL3Rva2VuIiwiemlkIjoidWFhIiwiYXVkIjpbIm9wZW5pZCIsImFpcnBvcnRzIl19.x2R0O5NYlQ3Lg03EwDkX2YFm-ytxAtpz2bONHirdS5nBeC_dES2W50l4DwFdsABSeycSSVSGqh-HW4eFmtuX1xDelENrUid4n6-NHmUjRtjd5mK_ZFL1w1vUfmYJH8icVALuy6IEEeUTFbB7HcL4Xlq6cc6Vd2VujYYfYb4wPBth5eNDIE2xMvAeqzwwF331lyWFZs7fHiK8GX564CStdCiLM48tB-Y30RVZl0vAUORlvvGx4OR-MXtqCyqU00ROA8f7tklHJqRCjMMvuBEw8bqhx-DXlZEJH4BDWMy4baVYH2ghBE-yq-o2rfluwwhoN97KwlYwNYbbZ-wfu7x5vQ",
  "token_type": "bearer",
  "refresh_token": "f77e1462f9494e6895639e7d1626c763-r",
  "expires_in": 43199,
  "scope": "openid airports.all",
  "jti": "c6409f738a27496ea17f595850ce2032"
}
```

## JWT refresh tokens

The UAA offers an alternate refresh token - all the metadata for refreshing access tokens is encoded inside the refresh token. The decoded data is JSON and it is in a format that looks very similar to a normal access token. A JWT refresh token, like a JWT access token, is encoded as a JSON Web Token.

As at the time of writing, the UAA publishes JWT refresh tokens that look so identical to JWT access tokens that the UAA will accidentally accept a JWT refresh token in liue of an access token - either by accident of the client application or by malicious misintent by users.
