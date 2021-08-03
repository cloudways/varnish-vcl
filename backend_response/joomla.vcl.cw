# Don't allow static assets to set cookies
        if (bereq.url ~ "\.(png|jpg|gif|css|js|swf|flv|ico|xml|txt|pdf|doc|woff|eot|mp[34]|svg|svgz)$"
# Force caching certain URLs by adding them below
#               || bereq.url ~ "/blog/"
                ) {
                unset beresp.http.set-cookie;
        }

# Set the X-URL variable for the ban lurker
        set beresp.http.x-url = bereq.url;

# Don't cache common Joomla extensions - add more URL patterns here and remove ones you don't need
        if( 
                # Don't cache URLs containing this string
                (bereq.url ~ ".*(log-in.html|create-an-account.html|captchaindex.php|community.html|com_comprofiler|kickstart.php|installation|com_users|task=addJS|view=registration|updatecart).*") ||
                # Don't cache URLs starting with this string
                bereq.url ~ "^/(cart|login)" ||
                # Don't cache if these cookies are being set
                (beresp.http.set-cookie ~ "cb_web_session") ||
                # Don't cache files with these extensions, if they're in the root directory
                (bereq.url ~ "^/[^/]\.(ini|zip|jpa)$")
        ) {
                return(deliver);
        }

# Joomla tells us this page is anonymous - unset all cookies
        if (beresp.http.X-MScale-Anonymous ~ "True")
        {
                unset beresp.http.set-cookie;
#               unset beresp.http.X-MScale-Anonymous;
        }

# Force minimum ttl of 4 hours
        if (beresp.ttl < 30m) {
                set beresp.ttl = 4h;
        }
include "/etc/varnish/varnish_default_ttl.vcl";

