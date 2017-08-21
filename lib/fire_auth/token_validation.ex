defmodule FireAuth.TokenValidation do
  require Logger
  require FireAuth.RecordHelper

  alias FireAuth.RecordHelper

  def validate_token(token_string) do
    token = Joken.token(token_string)
    header = Joken.peek_header(token)

    case verify_token(token, header) do
      {:ok, %{error: nil, claims: claims}} ->
        if check_token_claims(claims) do
          {:ok, %{
            name: claims["name"],
            id: claims["sub"],
            email: claims["email"],
            email_verified: claims["email_verified"]
          }}
        else
          {:error, %{message: "Token claims are invalid. (The token might be  experienced)"}}
        end
      {:ok, %{error: error}} ->
        {:error, %{message: "Token verifikation failed.", reason: error}}
      {:error, error} ->
        {:error, %{message: error}}
    end
  end

  defp check_token_claims(claims) do
    check_token_claims_exp(claims) &&
    check_token_claims_iat(claims) &&
    check_token_claims_aud(claims) &&
    check_token_claims_iss(claims)
  end

  defp check_token_claims_exp(claims), do: Joken.current_time() <= claims["exp"]
  defp check_token_claims_iat(claims), do: Joken.current_time() >= claims["iat"]
  defp check_token_claims_aud(claims), do: project_id() == claims["aud"]
  defp check_token_claims_iss(claims), do: "https://securetoken.google.com/#{project_id()}" == claims["iss"]

  defp verify_token(token, %{"alg" => "RS256", "kid" => kid}) do
    cert = Map.get(FireAuth.KeyServer.get_keybase() ,kid)

    case cert do
      nil ->
        Logger.debug("Could not find public certificate matching token kid.")
        {:error, "Could not find public certificate matching token kid."}
      cert ->
        Logger.debug("Certificate Found. Verifying token.")

        # Read the certificate
        pemEntries = :public_key.pem_decode(cert)
        {_, certEntry} = :lists.keysearch(:Certificate, 1, pemEntries)
        {_, derCert, _} = certEntry
        decoded = :public_key.pkix_decode_cert(derCert, :otp)

        otp_certificate = RecordHelper.otp_certificate(decoded, :tbsCertificate)
        public_key_info = RecordHelper.otptbs_certificate(otp_certificate, :subjectPublicKeyInfo)
        public_key = RecordHelper.otp_subject_public_key_info(public_key_info, :subjectPublicKey)

        jwk = JOSE.JWK.from_key(public_key)

        # Validate the token
        # This returns the token with possible verify errors
        verified_token = token
                          |> Joken.with_signer(Joken.rs256(jwk))
                          |> Joken.verify

        {:ok, verified_token}
    end
  end
  defp verify_token(_, _) do
    {:error, "Wrong algorithm in token header."}
  end

  defp project_id() do
    Application.get_env(:fire_auth, :project_id)
  end
end
