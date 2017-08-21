defmodule FireAuth.Util do
  @moduledoc """
  Utility functions used in the project.
  This includes primarily functions that help mocking data in tests.

  Also defines erlang records needed in the project.
  """
  require Record

  Record.defrecord :otp_certificate, 
                      Record.extract(:"OTPCertificate", from_lib: "public_key/asn1/OTP-PUB-KEY.hrl")
  Record.defrecord :otptbs_certificate, 
                      Record.extract(:"OTPTBSCertificate", from_lib: "public_key/asn1/OTP-PUB-KEY.hrl")
  Record.defrecord :otp_subject_public_key_info, 
                      Record.extract(:"OTPSubjectPublicKeyInfo", from_lib: "public_key/asn1/OTP-PUB-KEY.hrl")


  @doc """
  Helper function to get the current time.
  Mocks the time for tests.
  """
  def current_time() do
    {mega, secs, _} = :os.timestamp()
    current_time = mega * 1_000_000 + secs

    Application.get_env(:fire_auth, :current_time) || current_time 
  end

  @doc """
  Gets the HTTP client library to be used.
  Mocks the client library for tests.
  """
  def http_client() do
    Application.get_env(:fire_auth, :http_client) || HTTPotion
  end
end
