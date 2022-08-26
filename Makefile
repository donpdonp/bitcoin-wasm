# edit these directories
emsdk=../webasm/emsdk/ 
bitcoin_source = ../dogecoin
secp256k1_source = ../libsecp256k1-0.1\~20220711
wabt = ../webasm/wabt-1.0.0/

package_version = $(shell perl -ne 'print if s/\#define\s+PACKAGE_VERSION\s+"([\d.]+)"/\1/' $(bitcoin_source)/src/config/bitcoin-config.h )
bitcoin_client_major = $(shell perl -ne 'print if s/\#define\s+CLIENT_VERSION_MAJOR\s+(\d+)/\1/' $(bitcoin_source)/src/clientversion.h )
bitcoin_client_minor = $(shell perl -ne 'print if s/\#define\s+CLIENT_VERSION_MINOR\s+(\d+)/\1/' $(bitcoin_source)/src/clientversion.h )
bitcoin_client_revision = $(shell perl -ne 'print if s/\#define\s+CLIENT_VERSION_REVISION\s+(\d+)/\1/' $(bitcoin_source)/src/clientversion.h )

# project name
ifneq (,$(wildcard $(bitcoin_source)/src/dogecoin.h))
  project_name = dogecoin
else ifneq (,$(wildcard $(bitcoin_source)/src/bitcoin.h))
  project_name = bitcoin
else
  project_name = unknown
endif

#project_full_name = $(project_name) $(bitcoin_client_major).$(bitcoin_client_minor).$(bitcoin_client_revision)
project_full_name = $(project_name) $(package_version)

# files from bitcoin
bitcoin_files = script/interpreter.cpp script/script.cpp script/script_error.cpp crypto/ripemd160.cpp crypto/sha1.cpp \
                crypto/sha256.cpp primitives/transaction.cpp arith_uint256.cpp uint256.cpp \
				pubkey.cpp utilstrencodings.cpp
bitcoin_files_full = $(addprefix $(bitcoin_source)/src/, $(bitcoin_files))

openssl_source = openssl
openssl_files = 
openssl_ecdsa_files = ecs_lib.c ecs_asn1.c ecs_ossl.c ecs_sign.c ecs_vrf.c ecs_err.c
openssl_bn_files = bn_add.c bn_div.c bn_exp.c bn_lib.c bn_ctx.c bn_mul.c bn_mod.c \
	bn_print.c bn_rand.c bn_shift.c bn_word.c bn_blind.c \
	bn_kron.c bn_sqrt.c bn_gcd.c bn_prime.c bn_err.c bn_sqr.c bn_asm.c \
	bn_recp.c bn_mont.c bn_mpi.c bn_exp2.c bn_gf2m.c bn_nist.c \
	bn_depr.c bn_const.c bn_x931p.c
openssl_asn1_files = a_object.c a_bitstr.c a_utctm.c a_gentm.c a_time.c a_int.c a_octet.c \
	a_print.c a_type.c a_set.c a_dup.c a_d2i_fp.c a_i2d_fp.c \
	a_enum.c a_utf8.c a_sign.c a_digest.c a_verify.c a_mbstr.c a_strex.c \
	x_algor.c x_val.c x_pubkey.c x_sig.c x_req.c x_attrib.c x_bignum.c \
	x_long.c x_name.c x_x509.c x_x509a.c x_crl.c x_info.c x_spki.c nsseq.c \
	x_nx509.c d2i_pu.c d2i_pr.c i2d_pu.c i2d_pr.c\
	t_req.c t_x509.c t_x509a.c t_crl.c t_pkey.c t_spki.c t_bitst.c \
	tasn_new.c tasn_fre.c tasn_enc.c tasn_dec.c tasn_utl.c tasn_typ.c \
	tasn_prn.c ameth_lib.c \
	f_int.c f_string.c n_pkey.c \
	f_enum.c x_pkey.c a_bool.c x_exten.c bio_asn1.c bio_ndef.c asn_mime.c \
	asn1_gen.c asn1_par.c asn1_lib.c asn1_err.c a_bytes.c a_strnid.c \
	evp_asn1.c asn_pack.c p5_pbe.c p5_pbev2.c p8_pkey.c asn_moid.c

openssl_ec_files = ec_lib.c ecp_smpl.c ecp_mont.c ecp_nist.c ec_cvt.c ec_mult.c\
	ec_err.c ec_curve.c ec_check.c ec_print.c ec_asn1.c ec_key.c\
	ec2_smpl.c ec2_mult.c ec_ameth.c ec_pmeth.c eck_prn.c \
	ecp_nistp224.c ecp_nistp256.c ecp_nistp521.c ecp_nistputil.c \
	ecp_oct.c ec2_oct.c ec_oct.c

openssl_files_full = $(addprefix $(openssl_source)/, $(openssl_files)) 
#openssl_files_full = $(addprefix $(openssl_source)/, $(openssl_files)) \
#                     $(addprefix $(openssl_source)/crypto/ecdsa/, $(openssl_ecdsa_files)) \
#                     $(addprefix $(openssl_source)/crypto/bn/, $(openssl_bn_files)) \
#                     $(addprefix $(openssl_source)/crypto/ec/, $(openssl_ec_files)) \
#                     $(addprefix $(openssl_source)/crypto/asn1/, $(openssl_asn1_files))

openssl_flags = -I$(openssl_source) -I$(openssl_source)/crypto -I$(openssl_source)/include -I$(openssl_source)/crypto/asn1 \
                -I$(openssl_source)/crypto/evp $(openssl_files_full) -sLLD_REPORT_UNDEFINED

secp256k1_files = secp256k1.c precomputed_ecmult.c
secp256k1_files_full = -I $(secp256k1_source)/include $(addprefix $(secp256k1_source)/src/, $(secp256k1_files)) 

# bridge functions
exports = 'EXPORTED_FUNCTIONS=["_scriptRun","_scriptToString", "_stringCompile", "_decompile", "_version", "_byteCompile", "_getOpName"]'
export_extras = 'EXPORTED_RUNTIME_METHODS=["cwrap","ccall", "writeAsciiToMemory", "writeArrayToMemory", "getValue"]'
binaryen_methods = 'BINARYEN_METHOD="native-wasm,interpret-binary"'

# misc
build = ./build

all: build $(build)/$(project_name).wasm

#emscripten
$(build)/$(project_name).wasm: src/*.cpp
	@echo building for $(project_full_name)
	emcc -s $(exports) -s $(export_extras) -s WASM=1 -D PROJECT_NAME="\"$(project_full_name)\"" -o $(build)/$(project_name).js \
		-I ../libsecp256k1-0.1\~20220711/include -I$(bitcoin_source)/src $(bitcoin_files_full)\
		$(secp256k1_files_full) \
		 $(openssl_flags) $(openssl_files_full) $^
	ls -l $(build)/$(project_name)* 

build:
	mkdir $(build)

clean:
	rm -f $(build)/*.o $(build)/*.wasm $(build)/*.wast $(build)/*.js $(build)/*.map

node:
	cd build; node ../run.js
