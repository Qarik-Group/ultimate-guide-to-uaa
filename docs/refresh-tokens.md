# Refresh Tokens

The UAA offers refresh tokens to allow client applications to routinely check their authority to act on behalf of a user. I think you need to know what they are, when to use them, and why the UAA default configuration is wrong.

## Access Tokens and Refresh Tokens

When a user initially authenticates themselves with a UAA/OAuth2 authentication server we put them through the riggers of proving their identity - they must provide their email and password, maybe a multi-factor authentication/2FA challenge where they must get their phone out of their pocket, and the user may need to explicitly grant authorization to that client application to access some of their personal data. In exchange, the client application receives an access token that it can use for a limited amount of time. The access token is encoded using JWT which allows different client applications to decode it many times to discover who the user is, what scopes the application is permitted to access for the user, and how much longer this access token is valid.

Eventually an access token expires and client applications should stop assuming its contents are valid. The user might no longer wish to authorize that application to access the same scope of their personal data, the user might have revoked authorization to the client applications entirely, or conversely the user themselves might no longer have access to some groups/scopes/permissions. When an access token expires each client application would need each user to login via the UAA/OAuth2 authorization server again. OMG that would be tedious for everyone.

Instead, when a user initially authenticates with the UAA the client applications are provided with both an "access token" for immediate authorization to act on behalf of the user, and a "refresh token" to allow them to ask for new access tokens in future.

When an access token expires - the [default is 12 hours](https://github.com/cloudfoundry/uaa-release/blob/08b170e1f85846a6b85aa56c6104d791977fb17e/jobs/uaa/spec#L593-L595) - a client application should not give up on the user. Instead it should go back to the UAA with the refresh token and ask "please refresh my access token". The UAA will provide the client application with a new access token which will be valid another 12 hours.

A quick summary of the differences between access tokens and refresh tokens:

* Access tokens are passed from client application to backend API/resource server to authenticate and authorize access to data.
* Access tokens have a short life span - a security vs performance trade off between client applications always having to ask the UAA for authorization vs some offline caching of recently granted authorization.
* Client applications should not accept access tokens if they have expired, instead they should require their user to login again they should ask the UAA to refresh their access token.
* Refresh tokens are passed from client applications to the UAA to request a new access token with an longer time til expiry.
* Refresh tokens might never expire, or may have very long expiry times. The [default is 30 days](https://github.com/cloudfoundry/uaa-release/blob/08b170e1f85846a6b85aa56c6104d791977fb17e/jobs/uaa/spec#L596-L598).

## Refresh Token Implementations

The UAA offers two types of refresh tokens - opaque and JWT. As a client application developer, as a UAA operator, or as a security person, you need to know the difference and why I believe the UAA default configuration is currently wrong.

JWT refresh tokens look so much like access tokens, yet they have much longer expiry times, that client applications can be easily tricked into accepting them as access tokens. Sadly, the UAA default configuration is to provide JWT refresh tokens. In the rest of this section we will discuss opaque refresh tokens and JWT refresh tokens, why you should explicitly configure your UAA to only publish opaque refresh tokens, and how to emulate the security flaw in JWT refresh tokens.

## Opaque Refresh Tokens

Opaque refresh tokens look very different from access tokens. They are a short text string that means nothing to anyone outside of the UAA itself. That is, when the UAA publishes an opaque refresh token it stores all the metadata for the refresh token in its database and the refresh token is a reference.

```text
uaa get-password-token airports -s airports -u airports-all -p airports-all
uaa context
```

The output will look similar to:

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

We can confirm that the refresh token above is not encoded in JWT format:

![opaque-refresh-token-not-jwt-encoded](images/opaque-refresh-token-not-jwt-encoded.png)

That is the "opaque" aspect of opaque refresh tokens - they do not contain any information inside them; only the UAA itself can convert these tokens into the original metadata used to refresh the access token for a user.

It goes without saying that an opaque refresh token could not easily be confused with an access token - by either client applications that receive them from the UAA, nor resource server/backend applications to which they are passed when accessing data. This is a good thing. Refresh tokens and access tokens have a different purpose, and they have vastly different lifespans (hours vs months).

The opaque refresh token is also small. It can be easily stored in the small browser cookies, together with the larger access token.

## JWT Refresh Tokens

The UAA offers an alternate refresh token - all the metadata for refreshing access tokens is encoded inside the refresh token. The decoded data is JSON and it is in a format that looks very similar to a normal access token. A JWT refresh token, like a JWT access token, is encoded as a JSON Web Token.

As at the time of writing, the UAA publishes JWT refresh tokens that look so identical to JWT access tokens that the UAA will accidentally accept a JWT refresh token in liue of an access token - either by accident of the client application or by malicious misintent by users.

If we re-deploy our UAA to return JWT refresh tokens we can see that they look a lot like access tokens:

```json
{
  "client_id": "airports",
  "grant_type": "password",
  "username": "airports-all",
  "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6InVhYS1qd3Qta2V5LTEiLCJ0eXAiOiJKV1QifQ.eyJqdGkiOiJmZTM5MzIzNDY0ZDc0ZmI1YTZmY2I3MWQ4OWY3MjJjNCIsInN1YiI6IjQ4YThkNDY0LTEyZGQtNGIxNC1iN2EwLTk2YWY1ODM3OWZmYiIsInNjb3BlIjpbIm9wZW5pZCIsImFpcnBvcnRzLmFsbCJdLCJjbGllbnRfaWQiOiJhaXJwb3J0cyIsImNpZCI6ImFpcnBvcnRzIiwiYXpwIjoiYWlycG9ydHMiLCJncmFudF90eXBlIjoicGFzc3dvcmQiLCJ1c2VyX2lkIjoiNDhhOGQ0NjQtMTJkZC00YjE0LWI3YTAtOTZhZjU4Mzc5ZmZiIiwib3JpZ2luIjoidWFhIiwidXNlcl9uYW1lIjoiYWlycG9ydHMtYWxsIiwiZW1haWwiOiJhaXJwb3J0cy1hbGxAZXhhbXBsZS5jb20iLCJhdXRoX3RpbWUiOjE1MzA3Mzk5NzAsInJldl9zaWciOiI0YzNiMzgxMCIsImlhdCI6MTUzMDczOTk3MSwiZXhwIjoxNTMwNzgzMTcxLCJpc3MiOiJodHRwczovLzE5Mi4xNjguNTAuNjo4NDQzL29hdXRoL3Rva2VuIiwiemlkIjoidWFhIiwiYXVkIjpbIm9wZW5pZCIsImFpcnBvcnRzIl19.eMjU01Nymsxz_9DZtAKhWAdVzu3KqBwFyuydKIbbqawINkEm0xUXLholF8J4TQBG-V6PwsyG6J5s1p-r8KtiAzcZJMEKdB9naVgTE-KeNaO_DR0eFYkl19oES6vZOTap6SKk9mvP8S5dyt1eR5BcrmGY_O-K8IF0bbjJaU_YiI3oJdizWGXGcUVdEI6YM5IZjD17dQ9r6mWYKRvEQ26WEJw-vTrOyLNRLYupJwnDoUiZDzI2J84vKJCrCThWrTc1x-mSZOV7e9-G2Lh0QLDrnp1R3f4j68Kt31KiK8oV_ANIx_gWXV1EyJKhsR_zmVm7qL9WscTRP0KI3mSgok4LJg",
  "refresh_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6InVhYS1qd3Qta2V5LTEiLCJ0eXAiOiJKV1QifQ.eyJqdGkiOiIzZTUzOTU1ZmNmZjY0MjlhOGExODdjNGMzN2YxYjU5Mi1yIiwic3ViIjoiNDhhOGQ0NjQtMTJkZC00YjE0LWI3YTAtOTZhZjU4Mzc5ZmZiIiwic2NvcGUiOlsib3BlbmlkIiwiYWlycG9ydHMuYWxsIl0sImlhdCI6MTUzMDczOTk3MSwiZXhwIjoxNTMzMzMxOTcwLCJjaWQiOiJhaXJwb3J0cyIsImNsaWVudF9pZCI6ImFpcnBvcnRzIiwiaXNzIjoiaHR0cHM6Ly8xOTIuMTY4LjUwLjY6ODQ0My9vYXV0aC90b2tlbiIsInppZCI6InVhYSIsImdyYW50X3R5cGUiOiJwYXNzd29yZCIsInVzZXJfbmFtZSI6ImFpcnBvcnRzLWFsbCIsIm9yaWdpbiI6InVhYSIsInVzZXJfaWQiOiI0OGE4ZDQ2NC0xMmRkLTRiMTQtYjdhMC05NmFmNTgzNzlmZmIiLCJyZXZfc2lnIjoiNGMzYjM4MTAiLCJhdWQiOlsib3BlbmlkIiwiYWlycG9ydHMiXX0.xaV0AJbHpJHzmAiQUVCaqWsk_RQmPNIaBwwItEeJPWI559gVbONs2D-zOO1izDMapp77l52BcMz3fYJIwg6L7ecio9XFkfx3k8XBFY7pVIREwcc_Tm55K-36IJuuY0yELQ9KLKKTOzkRLCeAWurJa_P7Y2pB3aTOHO_79IeRaIbfq6yWmUKk1P4f7J1bFm7EQScZNgbt3aursoqqsNjBpbtMbw4LorbMXd7oQlzb-7ou6kv9eJyy-Ez6ryKqOBBxTCnYxrlq83AiFWRQ-rxYHcFll-c1OACyMsdfApJq_T0BEp8h_fAZdJ8u-WdsX886JHvDwhX3XToIcN86KvrJGQ",
  "id_token": "",
  "token_type": "bearer",
  "expires_in": 43199,
  "scope": "openid airports.all",
  "jti": "fe39323464d74fb5a6fcb71d89f722c4"
}
```

A JWT refresh token is large. It turns out that web applications will struggle to store both the JWT access token and JWT refresh token in their cookie-based sessions for each user. This results in web applications needing to do more work to store the access and refresh tokens in a database. One benefit of providing opaque refresh tokens to client applications is their small size.

