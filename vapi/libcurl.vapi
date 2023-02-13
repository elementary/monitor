/*-
 * Copyright (c) 2010-2013 Giulio Paci <giuliopaci@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

[CCode (cheader_filename = "curl/curl.h")]
namespace Curl {
    [CCode (cname = "CURL", cprefix = "curl_easy_", cheader_filename = "curl/curl.h", free_function = "curl_easy_cleanup")]
    [Compact]
    public class EasyHandle {
        [CCode (cname = "curl_easy_init")]
        public EasyHandle ();
        [CCode (cname = "curl_easy_cleanup")]
        public void cleanup ();
        [CCode (cname = "curl_easy_duphandle")]
        public Curl.EasyHandle duphandle ();
        [CCode (cname = "curl_easy_escape")]
        public string escape (string str, int length);
        [CCode (cname = "curl_easy_getinfo")]
        [PrintfFormat]
        public Curl.Code getinfo (Curl.Info info, ...);
        [CCode (cname = "curl_easy_pause")]
        public Curl.Code easy_pause (int bitmask);
        [CCode (cname = "curl_easy_perform")]
        public Curl.Code perform ();
        [CCode (cname = "curl_easy_recv")]
        public Curl.Code recv (void* buffer, size_t buflen, out size_t n);
        [CCode (cname = "curl_easy_reset")]
        public void reset ();
        [CCode (cname = "curl_easy_send")]
        public Curl.Code send (void* buffer, size_t buflen, out size_t n);
        [CCode (cname = "curl_easy_setopt")]
        [PrintfFormat]
        public Curl.Code setopt (Curl.Option option, ...);
        [CCode (cname = "curl_easy_unescape")]
        public string unescape (string str, int length, out int outlength);
    }
    namespace Global {
        [CCode (cname = "curl_free")]
        public static void free (void* p);
        [CCode (cname = "curl_getdate")]
        public static ulong getdate (string p, ulong unused);
        [CCode (cname = "curl_global_cleanup")]
        public static void cleanup ();
        [CCode (cname = "curl_escape")]
        public static unowned string escape (string str, int length);
        [CCode (cname = "curl_global_init")]
        public static Curl.Code init (long flags);
        [CCode (cname = "curl_global_init_mem")]
        public static Curl.Code init_mem (long flags, Curl.MallocCallback m, Curl.FreeCallback f, Curl.ReallocCallback r, Curl.StrdupCallback s, Curl.CallocCallback c);
        [CCode (cname = "curl_unescape")]
        public static unowned string unescape (string str, int length);
        [CCode (cname = "curl_strequal")]
        public static int strequal (string s1, string s2);
        [CCode (cname = "curl_easy_strerror")]
        public static unowned string strerror (Curl.Code p1);
        [CCode (cname = "curl_strnequal")]
        public static int strnequal (string s1, string s2, size_t n);
        [CCode (cname = "curl_version")]
        public static unowned string version ();
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLM", free_function = "curl_multi_cleanup")]
    [Compact]
    public class MultiHandle {
        [CCode (cname = "curl_multi_add_handle")]
        public Curl.MultiCode add_handle (Curl.EasyHandle curl_handle);
        [CCode (cname = "curl_multi_assign")]
        public Curl.MultiCode multi_assign (Curl.Socket sockfd, void* sockp);
        [CCode (cname = "curl_multi_cleanup")]
        public Curl.MultiCode cleanup ();
        [CCode (cname = "curl_multi_fdset")]
        public Curl.MultiCode fdset (Posix.fd_set read_fd_set, Posix.fd_set write_fd_set, Posix.fd_set exc_fd_set, int max_fd);
        [CCode (cname = "curl_multi_info_read")]
        public unowned Curl.Message info_read (int msgs_in_queue);
        [CCode (cname = "curl_multi_init")]
        public MultiHandle();
        [CCode (cname = "curl_multi_perform")]
        public Curl.MultiCode perform (int running_handles);
        [CCode (cname = "curl_multi_remove_handle")]
        public Curl.MultiCode remove_handle (Curl.EasyHandle curl_handle);
        [CCode (cname = "curl_multi_setopt")]
        public Curl.MultiCode setopt (Curl.MultiOption option);
        [CCode (cname = "curl_multi_socket")]
        public Curl.MultiCode socket (Curl.Socket s, int running_handles);
        [CCode (cname = "curl_multi_socket_action")]
        public Curl.MultiCode socket_action (Curl.Socket s, int ev_bitmask, int running_handles);
        [CCode (cname = "curl_multi_socket_all")]
        public Curl.MultiCode socket_all (int running_handles);
        [CCode (cname = "curl_multi_strerror")]
        public static unowned string strerror (Curl.MultiCode p1);
        [CCode (cname = "curl_multi_timeout")]
        public Curl.MultiCode timeout (long milliseconds);
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_offset_t")]
    [Compact]
    public class Offset {}
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLSH", free_function = "curl_share_cleanup")]
    [Compact]
    public class SharedHandle {
        [CCode (cname = "curl_share_cleanup")]
        public Curl.SharedCode cleanup ();
        [CCode (cname = "curl_share_init")]
        public SharedHandle ();
        [CCode (cname = "curl_share_setopt")]
        public Curl.SharedCode setopt (Curl.SharedOption option);
        [CCode (cname = "curl_share_strerror")]
        public static unowned string strerror (Curl.SharedCode p1);
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLMsg")]
    [Compact]
    public class Message {
        public Curl.Msg msg;
        public weak Curl.EasyHandle easy_handle;

        [CCode (cheader_filename = "curl/curl.h", cname = "union data")]
        [Compact]
        public struct Data
        {
            [CCode (cheader_filename = "curl/curl.h", cname = "whatever")]
            public void* whatever;
            [CCode (cheader_filename = "curl/curl.h", cname = "result")]
            public Curl.Code result;
        }
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_socket_t")]
    [Compact]
    public class Socket {}
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_version_info_data")]
    [Compact]
    public class VersionInfoData {
        public Curl.Version age;
        public weak string ares;
        public int ares_num;
        public int features;
        public weak string host;
        public int iconv_ver_num;
        public weak string libidn;
        public weak string libssh_version;
        public weak string libz_version;
        public weak string protocols;
        public weak string ssl_version;
        public long ssl_version_num;
        public weak string version;
        public uint version_num;
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "struct curl_httppost", free_function = "curl_formfree")]
    [Compact]
    public class HTTPPost {
        [CCode (cname = "curl_formadd")]
        public static Curl.FormCode formadd (out HTTPPost httppost, out HTTPPost last_post);
        [CCode (cname = "curl_formfree")]
        public void free ();
        [CCode (cname = "curl_formget")]
        public int get (void* arg, Curl.FormGetCallback append);
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "struct curl_slist", free_function = "curl_slist_free_all")]
    [Compact]
    public class SList {
        [CCode (cname = "curl_slist_append")]
        public static SList append (owned SList? p1, string p2);
        [CCode (cname = "curl_slist_free_all")]
        public void free_all ();
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_closepolicy", cprefix = "CURLCLOSEPOLICY_", has_type_id = false)]
    public enum ClosePolicy {
        NONE,
        OLDEST,
        LEAST_RECENTLY_USED,
        LEAST_TRAFFIC,
        SLOWEST,
        CALLBACK,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLcode", cprefix = "CURLE_", has_type_id = false)]
    public enum Code {
        OK,
        UNSUPPORTED_PROTOCOL,
        FAILED_INIT,
        URL_MALFORMAT,
        NOT_BUILT_IN,
        COULDNT_RESOLVE_PROXY,
        COULDNT_RESOLVE_HOST,
        COULDNT_CONNECT,
        FTP_WEIRD_SERVER_REPLY,
        REMOTE_ACCESS_DENIED,
        FTP_WEIRD_PASS_REPLY,
        FTP_WEIRD_PASV_REPLY,
        FTP_WEIRD_227_FORMAT,
        FTP_CANT_GET_HOST,
        FTP_COULDNT_SET_TYPE,
        PARTIAL_FILE,
        FTP_COULDNT_RETR_FILE,
        QUOTE_ERROR,
        HTTP_RETURNED_ERROR,
        WRITE_ERROR,
        UPLOAD_FAILED,
        READ_ERROR,
        OUT_OF_MEMORY,
        OPERATION_TIMEDOUT,
        FTP_PORT_FAILED,
        FTP_COULDNT_USE_REST,
        RANGE_ERROR,
        HTTP_POST_ERROR,
        SSL_CONNECT_ERROR,
        BAD_DOWNLOAD_RESUME,
        FILE_COULDNT_READ_FILE,
        LDAP_CANNOT_BIND,
        LDAP_SEARCH_FAILED,
        FUNCTION_NOT_FOUND,
        ABORTED_BY_CALLBACK,
        BAD_FUNCTION_ARGUMENT,
        INTERFACE_FAILED,
        TOO_MANY_REDIRECTS,
        UNKNOWN_OPTION,
        TELNET_OPTION_SYNTAX,
        PEER_FAILED_VERIFICATION,
        GOT_NOTHING,
        SSL_ENGINE_NOTFOUND,
        SSL_ENGINE_SETFAILED,
        SEND_ERROR,
        RECV_ERROR,
        SSL_CERTPROBLEM,
        SSL_CIPHER,
        SSL_CACERT,
        BAD_CONTENT_ENCODING,
        LDAP_INVALID_URL,
        FILESIZE_EXCEEDED,
        USE_SSL_FAILED,
        SEND_FAIL_REWIND,
        SSL_ENGINE_INITFAILED,
        LOGIN_DENIED,
        TFTP_NOTFOUND,
        TFTP_PERM,
        REMOTE_DISK_FULL,
        TFTP_ILLEGAL,
        TFTP_UNKNOWNID,
        REMOTE_FILE_EXISTS,
        TFTP_NOSUCHUSER,
        CONV_FAILED,
        CONV_REQD,
        SSL_CACERT_BADFILE,
        REMOTE_FILE_NOT_FOUND,
        SSH,
        SSL_SHUTDOWN_FAILED,
        AGAIN,
        SSL_CRL_BADFILE,
        SSL_ISSUER_ERROR,
        FTP_PRET_FAILED,
        RTSP_CSEQ_ERROR,
        RTSP_SESSION_ERROR,
        FTP_BAD_FILE_LIST,
        CHUNK_FAILED,
        [CCode (cname = "CURL_LAST")]
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curlfiletype", cprefix = "CURLFILETYPE_", has_type_id = false)]
    public enum FileType {
        FILE,
        DIRECTORY,
        SYMLINK,
        DEVICE_BLOCK,
        DEVICE_CHAR,
        NAMEDPIPE,
        SOCKET,
        DOOR,
        UNKNOWN
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLFORMcode", cprefix = "CURL_FORMADD_", has_type_id = false)]
    public enum FormCode {
        OK,
        MEMORY,
        OPTION_TWICE,
        NULL,
        UNKNOWN_OPTION,
        INCOMPLETE,
        ILLEGAL_ARRAY,
        DISABLED,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLformoption", cprefix = "CURLFORM_", has_type_id = false)]
    public enum FormOption {
        NOTHING,
        COPYNAME,
        PTRNAME,
        NAMELENGTH,
        COPYCONTENTS,
        PTRCONTENTS,
        CONTENTSLENGTH,
        FILECONTENT,
        ARRAY,
        OBSOLETE,
        FILE,
        BUFFER,
        BUFFERPTR,
        BUFFERLENGTH,
        CONTENTTYPE,
        CONTENTHEADER,
        FILENAME,
        END,
        OBSOLETE2,
        STREAM,
        LASTENTRY
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_ftpauth", cprefix = "CURLFTPAUTH_", has_type_id = false)]
    public enum FtpAuth {
        DEFAULT,
        SSL,
        TLS,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_ftpccc", cprefix = "CURLFTPSSL_CCC_", has_type_id = false)]
    public enum FtpCCC {
        NONE,
        PASSIVE,
        ACTIVE,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_ftpcreatedir", cprefix = "CURLFTP_CREATE_", has_type_id = false)]
    public enum FtpCreateDir {
        DIR_NONE,
        DIR,
        DIR_RETRY,
        DIR_LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_ftpmethod", cprefix = "CURLFTPMETHOD_", has_type_id = false)]
    public enum FtpMethod {
        DEFAULT,
        MULTICWD,
        NOCWD,
        SINGLECWD,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "httpversion", cprefix = "CURL_HTTP_VERION_", has_type_id = false)]
    public enum HttpVersion {
        @1_0,
        @1_1,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curlioerr", cprefix = "CURLIOCMD_", has_type_id = false)]
    public enum IOCmd {
        NOP,
        RESTARTREAD,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_ftpauth", cprefix = "CURLIOE_", has_type_id = false)]
    public enum IOError {
        OK,
        UNKNOWNCMD,
        FAILRESTART,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLINFO", cprefix = "CURLINFO_", has_type_id = false)]
    public enum Info {
        NONE,
        EFFECTIVE_URL,
        RESPONSE_CODE,
        TOTAL_TIME,
        NAMELOOKUP_TIME,
        CONNECT_TIME,
        PRETRANSFER_TIME,
        SIZE_UPLOAD,
        SIZE_DOWNLOAD,
        SPEED_DOWNLOAD,
        SPEED_UPLOAD,
        HEADER_SIZE,
        REQUEST_SIZE,
        SSL_VERIFYRESULT,
        FILETIME,
        CONTENT_LENGTH_DOWNLOAD,
        CONTENT_LENGTH_UPLOAD,
        STARTTRANSFER_TIME,
        CONTENT_TYPE,
        REDIRECT_TIME,
        REDIRECT_COUNT,
        PRIVATE,
        HTTP_CONNECTCODE,
        HTTPAUTH_AVAIL,
        PROXYAUTH_AVAIL,
        OS_ERRNO,
        NUM_CONNECTS,
        SSL_ENGINES,
        COOKIELIST,
        LASTSOCKET,
        FTP_ENTRY_PATH,
        REDIRECT_URL,
        PRIMARY_IP,
        APPCONNECT_TIME,
        CERTINFO,
        CONDITION_UNMET,
        RTSP_SESSION_ID,
        RTSP_CLIENT_CSEQ,
        RTSP_SERVER_CSEQ,
        RTSP_CSEQ_RECV,
        PRIMARY_PORT,
        LOCAL_IP,
        LOCAL_PORT,
        LASTONE
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_infotype", cprefix = "CURLINFO_", has_type_id = false)]
    public enum InfoType {
        TEXT,
        HEADER_IN,
        HEADER_OUT,
        DATA_IN,
        DATA_OUT,
        SSL_DATA_IN,
        SSL_DATA_OUT,
        END
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "keytype", cprefix = "CURLKHTYPE_", has_type_id = false)]
    public enum KeyHostKeyType {
        UNKNOWN,
        RSA1,
        RSA,
        DSS
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_khmatch", cprefix = "CURLKHMATCH_", has_type_id = false)]
    public enum KeyHostMatch {
        OK,
        MISMATCH,
        MISSING,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_khstat", cprefix = "CURLKHSTAT_", has_type_id = false)]
    public enum KeyHostStat {
        FINE_ADD_TO_FILE,
        FINE,
        REJECT,
        DEFER,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_lock_access", cprefix = "CURL_LOCK_ACCESS_", has_type_id = false)]
    public enum LockAccess {
        NONE,
        SHARED,
        SINGLE,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_lock_data", cprefix = "CURL_LOCK_DATA_", has_type_id = false)]
    public enum LockData {
        NONE,
        SHARE,
        COOKIE,
        DNS,
        SSL_SESSION,
        CONNECT,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLMSG", cprefix = "CURLMSG_", has_type_id = false)]
    public enum Msg {
        NONE,
        DONE,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLMcode", cprefix = "CURLM_", has_type_id = false)]
    public enum MultiCode {
        CALL_MULTI_PERFORM,
        OK,
        BAD_HANDLE,
        BAD_EASY_HANDLE,
        OUT_OF_MEMORY,
        INTERNAL_ERROR,
        BAD_SOCKET,
        UNKNOWN_OPTION,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLMoption", cprefix = "CURLMOPT_", has_type_id = false)]
    public enum MultiOption {
        SOCKETFUNCTION,
        SOCKETDATA,
        PIPELINING,
        TIMERFUNCTION,
        TIMERDATA,
        MAXCONNECTS,
        LASTENTRY
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURL_NETRC_OPTION", cprefix = "CURL_NETRC_", has_type_id = false)]
    public enum NetRCOption {
        IGNORED,
        OPTIONAL,
        REQUIRED,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLoption", cprefix = "CURLOPT_", has_type_id = false)]
    public enum Option {
        UNIX_SOCKET_PATH,
        FILE,
        WRITEDATA,
        URL,
        PORT,
        PROXY,
        USERPWD,
        PROXYUSERPWD,
        RANGE,
        INFILE,
        READDATA,
        ERRORBUFFER,
        WRITEFUNCTION,
        READFUNCTION,
        TIMEOUT,
        INFILESIZE,
        POSTFIELDS,
        REFERER,
        FTPPORT,
        USERAGENT,
        LOW_SPEED_LIMIT,
        LOW_SPEED_TIME,
        RESUME_FROM,
        COOKIE,
        HTTPHEADER,
        RTSPHEADER,
        HTTPPOST,
        SSLCERT,
        KEYPASSWD,
        CRLF,
        QUOTE,
        WRITEHEADER,
        HEADERDATA,
        COOKIEFILE,
        SSLVERSION,
        TIMECONDITION,
        TIMEVALUE,
        CUSTOMREQUEST,
        STDERR,
        POSTQUOTE,
        WRITEINFO,
        VERBOSE,
        HEADER,
        NOPROGRESS,
        NOBODY,
        FAILONERROR,
        UPLOAD,
        POST,
        DIRLISTONLY,
        APPEND,
        NETRC,
        FOLLOWLOCATION,
        TRANSFERTEXT,
        PUT,
        PROGRESSFUNCTION,
        PROGRESSDATA,
        AUTOREFERER,
        PROXYPORT,
        POSTFIELDSIZE,
        HTTPPROXYTUNNEL,
        INTERFACE,
        KRBLEVEL,
        SSL_VERIFYPEER,
        CAINFO,
        MAXREDIRS,
        FILETIME,
        TELNETOPTIONS,
        MAXCONNECTS,
        FRESH_CONNECT,
        FORBID_REUSE,
        RANDOM_FILE,
        EGDSOCKET,
        CONNECTTIMEOUT,
        HEADERFUNCTION,
        HTTPGET,
        SSL_VERIFYHOST,
        COOKIEJAR,
        SSL_CIPHER_LIST,
        HTTP_VERSION,
        FTP_USE_EPSV,
        SSLCERTTYPE,
        SSLKEY,
        SSLKEYTYPE,
        SSLENGINE,
        SSLENGINE_DEFAULT,
        DNS_CACHE_TIMEOUT,
        PREQUOTE,
        DEBUGFUNCTION,
        DEBUGDATA,
        COOKIESESSION,
        CAPATH,
        BUFFERSIZE,
        NOSIGNAL,
        SHARE,
        PROXYTYPE,
        ACCEPT_ENCODING,
        PRIVATE,
        HTTP200ALIASES,
        UNRESTRICTED_AUTH,
        FTP_USE_EPRT,
        HTTPAUTH,
        SSL_CTX_FUNCTION,
        SSL_CTX_DATA,
        FTP_CREATE_MISSING_DIRS,
        PROXYAUTH,
        FTP_RESPONSE_TIMEOUT,
        IPRESOLVE,
        MAXFILESIZE,
        INFILESIZE_LARGE,
        RESUME_FROM_LARGE,
        MAXFILESIZE_LARGE,
        NETRC_FILE,
        USE_SSL,
        POSTFIELDSIZE_LARGE,
        TCP_NODELAY,
        FTPSSLAUTH,
        IOCTLFUNCTION,
        IOCTLDATA,
        FTP_ACCOUNT,
        COOKIELIST,
        IGNORE_CONTENT_LENGTH,
        FTP_SKIP_PASV_IP,
        FTP_FILEMETHOD,
        LOCALPORT,
        LOCALPORTRANGE,
        CONNECT_ONLY,
        CONV_FROM_NETWORK_FUNCTION,
        CONV_TO_NETWORK_FUNCTION,
        CONV_FROM_UTF8_FUNCTION,
        MAX_SEND_SPEED_LARGE,
        MAX_RECV_SPEED_LARGE,
        FTP_ALTERNATIVE_TO_USER,
        SOCKOPTFUNCTION,
        SOCKOPTDATA,
        SSL_SESSIONID_CACHE,
        SSH_AUTH_TYPES,
        SSH_PUBLIC_KEYFILE,
        SSH_PRIVATE_KEYFILE,
        FTP_SSL_CCC,
        TIMEOUT_MS,
        CONNECTTIMEOUT_MS,
        HTTP_TRANSFER_DECODING,
        HTTP_CONTENT_DECODING,
        NEW_FILE_PERMS,
        NEW_DIRECTORY_PERMS,
        POSTREDIR,
        SSH_HOST_PUBLIC_KEY_MD5,
        OPENSOCKETFUNCTION,
        OPENSOCKETDATA,
        COPYPOSTFIELDS,
        PROXY_TRANSFER_MODE,
        SEEKFUNCTION,
        SEEKDATA,
        CRLFILE,
        ISSUERCERT,
        ADDRESS_SCOPE,
        CERTINFO,
        USERNAME,
        PASSWORD,
        PROXYUSERNAME,
        PROXYPASSWORD,
        NOPROXY,
        TFTP_BLKSIZE,
        SOCKS5_GSSAPI_SERVICE,
        SOCKS5_GSSAPI_NEC,
        PROTOCOLS,
        REDIR_PROTOCOLS,
        SSH_KNOWNHOSTS,
        SSH_KEYFUNCTION,
        SSH_KEYDATA,
        MAIL_FROM,
        MAIL_RCPT,
        FTP_USE_PRET,
        RTSP_REQUEST,
        RTSP_SESSION_ID,
        RTSP_STREAM_URI,
        RTSP_TRANSPORT,
        RTSP_CLIENT_CSEQ,
        RTSP_SERVER_CSEQ,
        INTERLEAVEDATA,
        INTERLEAVEFUNCTION,
        WILDCARDMATCH,
        CHUNK_BGN_FUNCTION,
        CHUNK_END_FUNCTION,
        FNMATCH_FUNCTION,
        CHUNK_DATA,
        FNMATCH_DATA,
        RESOLVE,
        TLSAUTH_USERNAME,
        TLSAUTH_PASSWORD,
        TLSAUTH_TYPE,
        TRANSFER_ENCODING,
        CLOSESOCKETFUNCTION,
        CLOSESOCKETDATA,
        LASTENTRY
    }
    [CCode (cheader_filename = "curl/curl.h", cprefix = "CURLPROXY_", has_type_id = false)]
    public enum ProxyType {
        HTTP,
        HTTP_1_0,
        SOCKS4,
        SOCKS5,
        SOCKS4A,
        SOCKS5_HOSTNAME
    }
    [CCode (cheader_filename = "curl/curl.h", cprefix = "CURL_RTSPREQ_", has_type_id = false)]
    public enum RTSPRequest {
        NONE,
        OPTIONS,
        DESCRIBE,
        ANNOUNCE,
        SETUP,
        PLAY,
        PAUSE,
        TEARDOWN,
        GET_PARAMETER,
        SET_PARAMETER,
        RECORD,
        RECEIVE,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "sslversion", cprefix = "CURL_SSLVERSION_", has_type_id = false)]
    public enum SSLVersion {
        DEFAULT,
        TLSv1,
        SSLv2,
        SSLv3,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLSHcode", cprefix = "CURLSHE_", has_type_id = false)]
    public enum SharedCode {
        OK,
        BAD_OPTION,
        IN_USE,
        INVALID,
        NOMEM,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLSHoption", cprefix = "CURLSHOPT_", has_type_id = false)]
    public enum SharedOption {
        NONE,
        SHARE,
        UNSHARE,
        LOCKFUNC,
        UNLOCKFUNC,
        USERDATA,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curlsocktype", cprefix = "CURLSOCKTYPE_", has_type_id = false)]
    public enum SocketType {
        IPCXN,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURL_TLSAUTH", cprefix = "CURL_TLSAUTH_", has_type_id = false)]
    public enum TLSAuth {
        NONE,
        SRP,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_TimeCond", cprefix = "CURL_TIMECOND_", has_type_id = false)]
    public enum TimeCond {
        NONE,
        IFMODSINCE,
        IFUNMODSINCE,
        LASTMOD,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_usessl", cprefix = "CURLUSESSL_", has_type_id = false)]
    public enum UseSSL {
        NONE,
        TRY,
        CONTROL,
        ALL,
        LAST
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "CURLversion", cprefix = "CURLVERSION_", has_type_id = false)]
    public enum Version {
        FIRST,
        SECOND,
        THIRD,
        FOURTH,
        NOW,
        LAST;
        [CCode (cname = "curl_version_info")]
        public unowned Curl.VersionInfoData info ();
    }
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_calloc_callback", has_target = false)]
    public delegate void* CallocCallback (size_t nmemb, size_t size);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_chunk_bgn_callback", has_target = false)]
    public delegate long ChunkBeginCallback (void* transfer_info, void* ptr, int remains);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_chunk_end_callback", has_target = false)]
    public delegate long ChunkEndCallback (void* ptr);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_closesocket_callback", has_target = false)]
    public delegate int CloseSocketCallback (void* clientp, Curl.Socket item);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_conv_callback", has_target = false)]
    public delegate Curl.Code ConvCallback (string buffer, size_t length);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_debug_callback", has_target = false)]
    public delegate int DebugCallback (Curl.EasyHandle handle, Curl.InfoType type, string data, size_t size, void* userptr);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_fnmatch_callback", has_target = false)]
    public delegate int FNMatchCallback (void* ptr, string pattern, string str);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_formget_callback", has_target = false)]
    public delegate size_t FormGetCallback (void* arg, string buf, size_t len);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_free_callback", has_target = false)]
    public delegate void FreeCallback (void* ptr);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_ioctl_callback", has_target = false)]
    public delegate Curl.IOError IOCtlCallback (Curl.EasyHandle handle, int cmd, void* clientp);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_lock_function", has_target = false)]
    public delegate void LockFunction (Curl.EasyHandle handle, Curl.LockData data, Curl.LockAccess locktype, void* userptr);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_malloc_callback", has_target = false)]
    public delegate void* MallocCallback (size_t size);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_multi_timer_callback", has_target = false)]
    public delegate int MultiTimerCallback (Curl.MultiHandle multi, long timeout_ms, void* userp);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_opensocket_callback", has_target = false)]
    public delegate unowned Curl.Socket OpenSocketCallback (void* clientp, Curl.SocketType purpose, void* address);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_progress_callback", has_target = false)]
    public delegate int ProgressCallback (void* clientp, double dltotal, double dlnow, double ultotal, double ulnow);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_read_callback", has_target = false)]
    public delegate size_t ReadCallback (char* buffer, size_t size, size_t nitems, void* instream);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_realloc_callback", has_target = false)]
    public delegate void* ReallocCallback (void* ptr, size_t size);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_sshkeycallback", has_target = false)]
    public delegate int SSHKeyCallback (Curl.EasyHandle easy, void* knownkey, void* foundkey, Curl.KeyHostMatch p4, void* clientp);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_ssl_ctx_callback", has_target = false)]
    public delegate Curl.Code SSLCtxCallback (Curl.EasyHandle curl, void* ssl_ctx, void* userptr);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_seek_callback", has_target = false)]
    public delegate int SeekCallback (void* instream, Curl.Offset offset, int origin);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_socket_callback", has_target = false)]
    public delegate int SocketCallback (Curl.EasyHandle easy, Curl.Socket s, int what, void* userp, void* socketp);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_sockopt_callback", has_target = false)]
    public delegate int SockoptCallback (void* clientp, Curl.Socket curlfd, Curl.SocketType purpose);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_strdup_callback", has_target = false)]
    public delegate unowned string StrdupCallback (string str);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_unlock_function", has_target = false)]
    public delegate void UnlockFunction (Curl.EasyHandle handle, Curl.LockData data, void* userptr);
    [CCode (cheader_filename = "curl/curl.h", cname = "curl_write_callback", has_target = false)]
    public delegate size_t WriteCallback (char* buffer, size_t size, size_t nitems, void* outstream);
    [CCode (cname = "CURL_WRITEFUNC_PAUSE", cheader_filename = "curl/curl.h")]
    public const size_t WRITEFUNC_PAUSE;
    [CCode (cname = "CURL_READFUNC_ABORT", cheader_filename = "curl/curl.h")]
    public const size_t READFUNC_ABORT;
    [CCode (cname = "CURL_READFUNC_PAUSE", cheader_filename = "curl/curl.h")]
    public const size_t READFUNC_PAUSE;
    [CCode (cname = "CURL_CHUNK_BGN_FUNC_SKIP", cheader_filename = "curl/curl.h")]
    public const int CHUNK_BGN_FUNC_SKIP;
    [CCode (cname = "CURL_CHUNK_END_FUNC_FAIL", cheader_filename = "curl/curl.h")]
    public const int CHUNK_END_FUNC_FAIL;
    [CCode (cname = "CURL_CHUNK_END_FUNC_OK", cheader_filename = "curl/curl.h")]
    public const int CHUNK_END_FUNC_OK;
    [CCode (cname = "CURL_CSELECT_ERR", cheader_filename = "curl/curl.h")]
    public const int CSELECT_ERR;
    [CCode (cname = "CURL_CSELECT_IN", cheader_filename = "curl/curl.h")]
    public const int CSELECT_IN;
    [CCode (cname = "CURL_CSELECT_OUT", cheader_filename = "curl/curl.h")]
    public const int CSELECT_OUT;
    [CCode (cname = "CURL_CURLAUTH_ANYSAFE", cheader_filename = "curl/curl.h")]
    public const int CURLAUTH_ANYSAFE;
    [CCode (cname = "CURL_CURLAUTH_BASIC", cheader_filename = "curl/curl.h")]
    public const int CURLAUTH_BASIC;
    [CCode (cname = "CURL_CURLAUTH_DIGEST", cheader_filename = "curl/curl.h")]
    public const int CURLAUTH_DIGEST;
    [CCode (cname = "CURL_CURLAUTH_DIGEST_IE", cheader_filename = "curl/curl.h")]
    public const int CURLAUTH_DIGEST_IE;
    [CCode (cname = "CURL_CURLAUTH_GSSNEGOTIATE", cheader_filename = "curl/curl.h")]
    public const int CURLAUTH_GSSNEGOTIATE;
    [CCode (cname = "CURL_CURLAUTH_NONE", cheader_filename = "curl/curl.h")]
    public const int CURLAUTH_NONE;
    [CCode (cname = "CURL_CURLAUTH_NTLM", cheader_filename = "curl/curl.h")]
    public const int CURLAUTH_NTLM;
    [CCode (cname = "CURL_CURLAUTH_ONLY", cheader_filename = "curl/curl.h")]
    public const int CURLAUTH_ONLY;
    [CCode (cname = "CURL_CURLINFO_DOUBLE", cheader_filename = "curl/curl.h")]
    public const int CURLINFO_DOUBLE;
    [CCode (cname = "CURL_CURLINFO_LONG", cheader_filename = "curl/curl.h")]
    public const int CURLINFO_LONG;
    [CCode (cname = "CURL_CURLINFO_MASK", cheader_filename = "curl/curl.h")]
    public const int CURLINFO_MASK;
    [CCode (cname = "CURL_CURLINFO_SLIST", cheader_filename = "curl/curl.h")]
    public const int CURLINFO_SLIST;
    [CCode (cname = "CURL_CURLINFO_STRING", cheader_filename = "curl/curl.h")]
    public const int CURLINFO_STRING;
    [CCode (cname = "CURL_CURLINFO_TYPEMASK", cheader_filename = "curl/curl.h")]
    public const int CURLINFO_TYPEMASK;
    [CCode (cname = "CURL_CURLOPTTYPE_FUNCTIONPOINT", cheader_filename = "curl/curl.h")]
    public const int CURLOPTTYPE_FUNCTIONPOINT;
    [CCode (cname = "CURL_CURLOPTTYPE_LONG", cheader_filename = "curl/curl.h")]
    public const int CURLOPTTYPE_LONG;
    [CCode (cname = "CURL_CURLOPTTYPE_OBJECTPOINT", cheader_filename = "curl/curl.h")]
    public const int CURLOPTTYPE_OBJECTPOINT;
    [CCode (cname = "CURL_CURLOPTTYPE_OFF_T", cheader_filename = "curl/curl.h")]
    public const int CURLOPTTYPE_OFF_T;
    [CCode (cname = "CURL_CURLPAUSE_ALL", cheader_filename = "curl/curl.h")]
    public const int CURLPAUSE_ALL;
    [CCode (cname = "CURL_CURLPAUSE_CONT", cheader_filename = "curl/curl.h")]
    public const int CURLPAUSE_CONT;
    [CCode (cname = "CURL_CURLPAUSE_RECV", cheader_filename = "curl/curl.h")]
    public const int CURLPAUSE_RECV;
    [CCode (cname = "CURL_CURLPAUSE_RECV_CONT", cheader_filename = "curl/curl.h")]
    public const int CURLPAUSE_RECV_CONT;
    [CCode (cname = "CURL_CURLPAUSE_SEND", cheader_filename = "curl/curl.h")]
    public const int CURLPAUSE_SEND;
    [CCode (cname = "CURL_CURLPAUSE_SEND_CONT", cheader_filename = "curl/curl.h")]
    public const int CURLPAUSE_SEND_CONT;
    [CCode (cname = "CURL_CURLPROTO_ALL", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_ALL;
    [CCode (cname = "CURL_CURLPROTO_DICT", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_DICT;
    [CCode (cname = "CURL_CURLPROTO_FILE", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_FILE;
    [CCode (cname = "CURL_CURLPROTO_FTP", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_FTP;
    [CCode (cname = "CURL_CURLPROTO_FTPS", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_FTPS;
    [CCode (cname = "CURL_CURLPROTO_GOPHER", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_GOPHER;
    [CCode (cname = "CURL_CURLPROTO_HTTP", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_HTTP;
    [CCode (cname = "CURL_CURLPROTO_HTTPS", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_HTTPS;
    [CCode (cname = "CURL_CURLPROTO_IMAP", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_IMAP;
    [CCode (cname = "CURL_CURLPROTO_IMAPS", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_IMAPS;
    [CCode (cname = "CURL_CURLPROTO_LDAP", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_LDAP;
    [CCode (cname = "CURL_CURLPROTO_LDAPS", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_LDAPS;
    [CCode (cname = "CURL_CURLPROTO_POP3", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_POP3;
    [CCode (cname = "CURL_CURLPROTO_POP3S", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_POP3S;
    [CCode (cname = "CURL_CURLPROTO_RTMP", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_RTMP;
    [CCode (cname = "CURL_CURLPROTO_RTMPE", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_RTMPE;
    [CCode (cname = "CURL_CURLPROTO_RTMPS", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_RTMPS;
    [CCode (cname = "CURL_CURLPROTO_RTMPT", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_RTMPT;
    [CCode (cname = "CURL_CURLPROTO_RTMPTE", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_RTMPTE;
    [CCode (cname = "CURL_CURLPROTO_RTMPTS", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_RTMPTS;
    [CCode (cname = "CURL_CURLPROTO_RTSP", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_RTSP;
    [CCode (cname = "CURL_CURLPROTO_SCP", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_SCP;
    [CCode (cname = "CURL_CURLPROTO_SFTP", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_SFTP;
    [CCode (cname = "CURL_CURLPROTO_SMTP", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_SMTP;
    [CCode (cname = "CURL_CURLPROTO_SMTPS", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_SMTPS;
    [CCode (cname = "CURL_CURLPROTO_TELNET", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_TELNET;
    [CCode (cname = "CURL_CURLPROTO_TFTP", cheader_filename = "curl/curl.h")]
    public const int CURLPROTO_TFTP;
    [CCode (cname = "CURL_CURLSSH_AUTH_ANY", cheader_filename = "curl/curl.h")]
    public const int CURLSSH_AUTH_ANY;
    [CCode (cname = "CURL_CURLSSH_AUTH_HOST", cheader_filename = "curl/curl.h")]
    public const int CURLSSH_AUTH_HOST;
    [CCode (cname = "CURL_CURLSSH_AUTH_KEYBOARD", cheader_filename = "curl/curl.h")]
    public const int CURLSSH_AUTH_KEYBOARD;
    [CCode (cname = "CURL_CURLSSH_AUTH_NONE", cheader_filename = "curl/curl.h")]
    public const int CURLSSH_AUTH_NONE;
    [CCode (cname = "CURL_CURLSSH_AUTH_PASSWORD", cheader_filename = "curl/curl.h")]
    public const int CURLSSH_AUTH_PASSWORD;
    [CCode (cname = "CURL_CURLSSH_AUTH_PUBLICKEY", cheader_filename = "curl/curl.h")]
    public const int CURLSSH_AUTH_PUBLICKEY;
    [CCode (cname = "CURL_ERROR_SIZE", cheader_filename = "curl/curl.h")]
    public const int ERROR_SIZE;
    [CCode (cname = "CURL_FNMATCHFUNC_FAIL", cheader_filename = "curl/curl.h")]
    public const int FNMATCHFUNC_FAIL;
    [CCode (cname = "CURL_FNMATCHFUNC_MATCH", cheader_filename = "curl/curl.h")]
    public const int FNMATCHFUNC_MATCH;
    [CCode (cname = "CURL_FNMATCHFUNC_NOMATCH", cheader_filename = "curl/curl.h")]
    public const int FNMATCHFUNC_NOMATCH;
    [CCode (cname = "CURL_FORMAT_CURL_OFF_T", cheader_filename = "curl/curl.h")]
    public const string FORMAT_CURL_OFF_T;
    [CCode (cname = "CURL_FORMAT_CURL_OFF_TU", cheader_filename = "curl/curl.h")]
    public const string FORMAT_CURL_OFF_TU;
    [CCode (cname = "CURL_FORMAT_OFF_T", cheader_filename = "curl/curl.h")]
    public const string FORMAT_OFF_T;
    [CCode (cname = "CURL_GLOBAL_ALL", cheader_filename = "curl/curl.h")]
    public const int GLOBAL_ALL;
    [CCode (cname = "CURL_GLOBAL_DEFAULT", cheader_filename = "curl/curl.h")]
    public const int GLOBAL_DEFAULT;
    [CCode (cname = "CURL_GLOBAL_NOTHING", cheader_filename = "curl/curl.h")]
    public const int GLOBAL_NOTHING;
    [CCode (cname = "CURL_GLOBAL_SSL", cheader_filename = "curl/curl.h")]
    public const int GLOBAL_SSL;
    [CCode (cname = "CURL_GLOBAL_WIN32", cheader_filename = "curl/curl.h")]
    public const int GLOBAL_WIN32;
    [CCode (cname = "CURL_HTTPPOST_BUFFER", cheader_filename = "curl/curl.h")]
    public const int HTTPPOST_BUFFER;
    [CCode (cname = "CURL_HTTPPOST_CALLBACK", cheader_filename = "curl/curl.h")]
    public const int HTTPPOST_CALLBACK;
    [CCode (cname = "CURL_HTTPPOST_FILENAME", cheader_filename = "curl/curl.h")]
    public const int HTTPPOST_FILENAME;
    [CCode (cname = "CURL_HTTPPOST_PTRBUFFER", cheader_filename = "curl/curl.h")]
    public const int HTTPPOST_PTRBUFFER;
    [CCode (cname = "CURL_HTTPPOST_PTRCONTENTS", cheader_filename = "curl/curl.h")]
    public const int HTTPPOST_PTRCONTENTS;
    [CCode (cname = "CURL_HTTPPOST_PTRNAME", cheader_filename = "curl/curl.h")]
    public const int HTTPPOST_PTRNAME;
    [CCode (cname = "CURL_HTTPPOST_READFILE", cheader_filename = "curl/curl.h")]
    public const int HTTPPOST_READFILE;
    [CCode (cname = "CURL_IPRESOLVE_V4", cheader_filename = "curl/curl.h")]
    public const int IPRESOLVE_V4;
    [CCode (cname = "CURL_IPRESOLVE_V6", cheader_filename = "curl/curl.h")]
    public const int IPRESOLVE_V6;
    [CCode (cname = "CURL_IPRESOLVE_WHATEVER", cheader_filename = "curl/curl.h")]
    public const int IPRESOLVE_WHATEVER;
    [CCode (cname = "CURL_LIBCURL_COPYRIGHT", cheader_filename = "curl/curl.h")]
    public const string LIBCURL_COPYRIGHT;
    [CCode (cname = "CURL_LIBCURL_TIMESTAMP", cheader_filename = "curl/curl.h")]
    public const string LIBCURL_TIMESTAMP;
    [CCode (cname = "CURL_LIBCURL_VERSION", cheader_filename = "curl/curl.h")]
    public const string LIBCURL_VERSION;
    [CCode (cname = "CURL_LIBCURL_VERSION_MAJOR", cheader_filename = "curl/curl.h")]
    public const int LIBCURL_VERSION_MAJOR;
    [CCode (cname = "CURL_LIBCURL_VERSION_MINOR", cheader_filename = "curl/curl.h")]
    public const int LIBCURL_VERSION_MINOR;
    [CCode (cname = "CURL_LIBCURL_VERSION_NUM", cheader_filename = "curl/curl.h")]
    public const int LIBCURL_VERSION_NUM;
    [CCode (cname = "CURL_LIBCURL_VERSION_PATCH", cheader_filename = "curl/curl.h")]
    public const int LIBCURL_VERSION_PATCH;
    [CCode (cname = "CURL_POLL_IN", cheader_filename = "curl/curl.h")]
    public const int POLL_IN;
    [CCode (cname = "CURL_POLL_INOUT", cheader_filename = "curl/curl.h")]
    public const int POLL_INOUT;
    [CCode (cname = "CURL_POLL_NONE", cheader_filename = "curl/curl.h")]
    public const int POLL_NONE;
    [CCode (cname = "CURL_POLL_OUT", cheader_filename = "curl/curl.h")]
    public const int POLL_OUT;
    [CCode (cname = "CURL_POLL_REMOVE", cheader_filename = "curl/curl.h")]
    public const int POLL_REMOVE;
    [CCode (cname = "CURL_PULL_SYS_SOCKET_H", cheader_filename = "curl/curl.h")]
    public const int PULL_SYS_SOCKET_H;
    [CCode (cname = "CURL_PULL_SYS_TYPES_H", cheader_filename = "curl/curl.h")]
    public const int PULL_SYS_TYPES_H;
    [CCode (cname = "CURL_REDIR_GET_ALL", cheader_filename = "curl/curl.h")]
    public const int REDIR_GET_ALL;
    [CCode (cname = "CURL_REDIR_POST_301", cheader_filename = "curl/curl.h")]
    public const int REDIR_POST_301;
    [CCode (cname = "CURL_REDIR_POST_302", cheader_filename = "curl/curl.h")]
    public const int REDIR_POST_302;
    [CCode (cname = "CURL_REDIR_POST_ALL", cheader_filename = "curl/curl.h")]
    public const int REDIR_POST_ALL;
    [CCode (cname = "CURL_SEEKFUNC_CANTSEEK", cheader_filename = "curl/curl.h")]
    public const int SEEKFUNC_CANTSEEK;
    [CCode (cname = "CURL_SEEKFUNC_FAIL", cheader_filename = "curl/curl.h")]
    public const int SEEKFUNC_FAIL;
    [CCode (cname = "CURL_SEEKFUNC_OK", cheader_filename = "curl/curl.h")]
    public const int SEEKFUNC_OK;
    [CCode (cname = "CURL_SIZEOF_CURL_OFF_T", cheader_filename = "curl/curl.h")]
    public const int SIZEOF_CURL_OFF_T;
    [CCode (cname = "CURL_SIZEOF_CURL_SOCKLEN_T", cheader_filename = "curl/curl.h")]
    public const int SIZEOF_CURL_SOCKLEN_T;
    [CCode (cname = "CURL_SIZEOF_LONG", cheader_filename = "curl/curl.h")]
    public const int SIZEOF_LONG;
    [CCode (cname = "CURL_SOCKET_BAD", cheader_filename = "curl/curl.h")]
    public const int SOCKET_BAD;
    [CCode (cname = "CURL_VERSION_ASYNCHDNS", cheader_filename = "curl/curl.h")]
    public const int VERSION_ASYNCHDNS;
    [CCode (cname = "CURL_VERSION_CONV", cheader_filename = "curl/curl.h")]
    public const int VERSION_CONV;
    [CCode (cname = "CURL_VERSION_CURLDEBUG", cheader_filename = "curl/curl.h")]
    public const int VERSION_CURLDEBUG;
    [CCode (cname = "CURL_VERSION_DEBUG", cheader_filename = "curl/curl.h")]
    public const int VERSION_DEBUG;
    [CCode (cname = "CURL_VERSION_GSSNEGOTIATE", cheader_filename = "curl/curl.h")]
    public const int VERSION_GSSNEGOTIATE;
    [CCode (cname = "CURL_VERSION_IDN", cheader_filename = "curl/curl.h")]
    public const int VERSION_IDN;
    [CCode (cname = "CURL_VERSION_IPV6", cheader_filename = "curl/curl.h")]
    public const int VERSION_IPV6;
    [CCode (cname = "CURL_VERSION_KERBEROS4", cheader_filename = "curl/curl.h")]
    public const int VERSION_KERBEROS4;
    [CCode (cname = "CURL_VERSION_LARGEFILE", cheader_filename = "curl/curl.h")]
    public const int VERSION_LARGEFILE;
    [CCode (cname = "CURL_VERSION_LIBZ", cheader_filename = "curl/curl.h")]
    public const int VERSION_LIBZ;
    [CCode (cname = "CURL_VERSION_NTLM", cheader_filename = "curl/curl.h")]
    public const int VERSION_NTLM;
    [CCode (cname = "CURL_VERSION_SPNEGO", cheader_filename = "curl/curl.h")]
    public const int VERSION_SPNEGO;
    [CCode (cname = "CURL_VERSION_SSL", cheader_filename = "curl/curl.h")]
    public const int VERSION_SSL;
    [CCode (cname = "CURL_VERSION_SSPI", cheader_filename = "curl/curl.h")]
    public const int VERSION_SSPI;
    [CCode (cname = "CURL_VERSION_TLSAUTH_SRP", cheader_filename = "curl/curl.h")]
    public const int VERSION_TLSAUTH_SRP;
}
