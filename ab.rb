require 'formula'

class Ab < Formula
  homepage 'http://httpd.apache.org/docs/trunk/programs/ab.html'
  url 'http://www.apache.org/dist/httpd/httpd-2.4.12.tar.bz2'
  sha1 '8d391db515edfb6623c0c7c6ce5c1b2e1f7c64c2'

  def patches
      {
      # The ab tool of the latest stable httpd (2.4.2) does not work
      # properly on systems that have both IPv4 and IPv6, i.e. OS X machines
      # running Lion or later. In particular, the patch that added the `-B'
      # option to bind to a local address disables connections to IPv4 hosts:
      # "bind: Address family not supported by protocol family (47)"
      # This issue has been fixed in SVN revision 1351737, but a
      # packaged version with this fix is not yet available.
      # Therefore, we download version 2.4.2 and patch it.
      # As soon as the next version of httpd is released, presumably version
      # 2.4.3, this will no longer be necessary.
      :p3 => 'http://svn.apache.org/viewvc/httpd/httpd/trunk/support/ab.c?r1=1351737&r2=1351736&pathrev=1351737&view=patch',
      # Disable requirement for PCRE, because "ab" does not use it
      :p1 => DATA }
  end

  def install
    # Mountain Lion requires this to be set, as otherwise libtool complains
    # about being "unable to infer tagged configuration"
    ENV['LTFLAGS'] = '--tag CC'
    system "./configure", "--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"

    cd 'support' do
        system 'make', 'ab'
        # We install into the "bin" directory, although "ab" would normally be
        # installed to "/usr/sbin/ab"
        bin.install('ab')
    end
    man1.install('docs/man/ab.1')
  end

  def test
    print `"#{bin}/ab" -k -n 10 -c 10 http://www.apple.com/`
  end
end

__END__
diff --git a/configure b/configure
index 5f4c09f..84d3de2 100755
--- a/configure
+++ b/configure
@@ -6037,8 +6037,6 @@ $as_echo "$as_me: Using external PCRE library from $PCRE_CONFIG" >&6;}
     done
   fi
 
-else
-  as_fn_error $? "pcre-config for libpcre not found. PCRE is required and available from http://pcre.org/" "$LINENO" 5
 fi
 
   APACHE_VAR_SUBST="$APACHE_VAR_SUBST PCRE_LIBS"
