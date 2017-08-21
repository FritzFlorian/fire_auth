defmodule FireAuth.RecordHelper do
  @moduledoc """
  Helper Module that loads erlang record definitions needed for using the crypto functions.
  """
  require Record

  Record.defrecord :otp_certificate, 
                      Record.extract(:"OTPCertificate", from_lib: "public_key/asn1/OTP-PUB-KEY.hrl")
  Record.defrecord :otptbs_certificate, 
                      Record.extract(:"OTPTBSCertificate", from_lib: "public_key/asn1/OTP-PUB-KEY.hrl")
  Record.defrecord :otp_subject_public_key_info, 
                      Record.extract(:"OTPSubjectPublicKeyInfo", from_lib: "public_key/asn1/OTP-PUB-KEY.hrl")
end
