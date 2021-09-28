# Normalize the header, unset the port (in case you're testing this on various TCP ports)
set req.http.Host = regsub(req.http.Host, ":[0-9]+", "");
# Allow purging from ACL
# Post requests will not be cached
if (req.http.Authorization || req.method == "POST") {
return (pipe);
}
# --- Wordpress specific configuration
# Did not cache the RSS feed
if (req.url ~ "/feed" && req.method != "URLPURGE") {
return (pipe); #Changed to Pipe
}
# Blitz hack
if (req.url ~ "/mu-.*") {
return (pipe); #Changed to Pipe
}
# Did not cache the admin and login pages
if (req.url ~ "/(wp-login|wp-admin|wp-json|wp-cron|membership-account|membership-checkout)" && req.method != "URLPURGE") {
return (pipe); #Changed to Pipe
}
# Do not cache the WooCommerce pages
### REMOVE IT IF YOU DO NOT USE WOOCOMMERCE ###
if (req.url ~ "/(cart|my-account|checkout|wc-api|addons|\?add-to-cart=|add-to-cart|logout|lost-password|administrator|\?wc-ajax=get_refreshed_fragments)") {
return (pipe);
}

# Check the cookies for wordpress-specific items
if (req.http.Cookie ~ "wordpress_logged_in|resetpass|wp-postpass|wordpress_|comment_") {
        return (pipe); #Changed to Pipe
}

#fixed non AJAX cart problem
if (req.http.cookie ~ "woocommerce_(cart|session)|wp_woocommerce_session") {
return(pipe);
}

# Fix Wordpress visual editor issues
if (req.url ~ "/wp-(login|admin|comments-post.php|cron)" || req.url ~ "preview=true" || req.url ~ "xmlrpc.php") {
return (pipe);
}

#EDD Empty Cart Rules
if (req.url ~ "edd_action") {
return (pipe);
}
if (req.http.cookie ~ "(^|;\s*)edd") { 
return (pipe); 
}

# Strip out Google Analytics campaign variables.
#if (req.url ~ "(\?|&)(msclkid|gclid|dm_i|qid|mc_eid|mc_cid|fbclid|cx|ie|cof|siteurl|zanpid|origin|utm_[a-z]+|mr:[A-z]+)=") {
#set req.url = regsuball(req.url, "(gclid|fbclid|dm_i|qid|cx|ie|cof|mc_eid|mc_cid|siteurl|zanpid|origin|utm_[a-z]+|mr:[A-z]+)=[-_A-z0-9+()%.,]+&?", "");
#set req.url = regsub(req.url, "(\?&?)$", ""); }

#Cache everything else
if (!req.url ~ "/wp-(login|admin|cron)|logout|lost-password|wc-api|cart|my-account|checkout|addons|administrator|accounts|bookings|members|member|course|resetpass") {
unset req.http.cookie;
}

# Normalize Accept-Encoding header and compression
# https://www.varnish-cache.org/docs/3.0/tutorial/vary.html
if (req.http.Accept-Encoding) {
# Do no compress compressed files...
if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
unset req.http.Accept-Encoding;
} elsif (req.http.Accept-Encoding ~ "gzip") {
set req.http.Accept-Encoding = "gzip";
} elsif (req.http.Accept-Encoding ~ "deflate") {
set req.http.Accept-Encoding = "deflate";
} else {
unset req.http.Accept-Encoding;
}
}

if (!req.http.Cookie) {
unset req.http.Cookie;
}
# --- End of Wordpress specific configuration
# Did not cache HTTP authentication and HTTP Cookie
if (req.http.Authorization || req.http.Cookie) {
# Not cacheable by default
return (pipe); #Changed to Pipe
}
#Purging
if (req.method == "URLPURGE") {
        if (!client.ip ~ purge) {
           return(synth(405, "This IP is not allowed to send PURGE requests."));
        }
        return (purge);
}
if (req.method == "PURGE") {
                if (!client.ip ~ purge) {
                        return(synth(405, "Not allowed."));
                }
                ban("req.http.host ~ " + req.http.host);
                return (purge);
        }
#Baning
if (req.method == "BAN") {
                if (!client.ip ~ purge) {
                        return(synth(405, "This IP is not allowed to send PURGE requests."));
                }
                ban("req.http.host == " + req.http.host +
                      "&& req.url == " + req.url);
                return(synth(200, "Ban added"));
        }
  if (req.http.Accept-Encoding) {
    if (req.url ~ "\.(gif|jpg|jpeg|swf|flv|mp3|mp4|pdf|ico|png|gz|tgz|bz2)(\?.*|)$") {
      unset req.http.Accept-Encoding;
    } elsif (req.http.Accept-Encoding ~ "gzip") {
      set req.http.Accept-Encoding = "gzip";
    } elsif (req.http.Accept-Encoding ~ "deflate") {
      set req.http.Accept-Encoding = "deflate";
    } else {
      unset req.http.Accept-Encoding;
    }
  }
  if (req.url ~ "\.(gif|jpg|jpeg|swf|css|js|flv|mp3|mp4|pdf|ico|png)(\?.*|)$") {
    unset req.http.Cookie;
    set req.url = regsub(req.url, "\?.*$", "");
  }
  if (req.http.Cookie) {
    if (req.http.Cookie ~ "(wordpress_|wp-settings-)") {
        set req.backend_hint = admin;
      return(pipe); #Changed to Pipe
    } else {
      unset req.http.Cookie;
    }
  }
