
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <crypto/aead.h>
#include <linux/err.h>

#define TARGET_ALGO "ccm(aes)"

static int __init crypto_warmup_init(void)
{
    struct crypto_aead *tfm;

    pr_info("CryptoWarmup: Attempting to initialize %s\n", TARGET_ALGO);
    tfm = crypto_alloc_aead(TARGET_ALGO, 0, 0);

    if (IS_ERR(tfm)) {
        pr_err("CryptoWarmup: Failed to initialize %s. Error: %ld\n", 
                TARGET_ALGO, PTR_ERR(tfm));
        return PTR_ERR(tfm);
    }

    pr_info("CryptoWarmup: %s successfully initialized\n", TARGET_ALGO);
    crypto_free_aead(tfm);

    /* Return a non-zero value if you want the module to unload automatically 
       immediately after the warmup (e.g., return -EAGAIN;), 
       otherwise return 0 to stay loaded. */
    return -EAGAIN;
}

static void __exit crypto_warmup_exit(void)
{
    pr_info("CryptoWarmup: Module unloaded\n");
}

module_init(crypto_warmup_init);
module_exit(crypto_warmup_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("OpenWrt_User");
MODULE_DESCRIPTION("Standalone Kernel for ccm(aes) Crypto Warmup");