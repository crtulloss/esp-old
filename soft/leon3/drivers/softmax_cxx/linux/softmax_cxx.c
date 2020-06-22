#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "softmax_cxx.h"

#define DRV_NAME	"softmax_cxx"

/* <<--regs-->> */
#define SOFTMAX_CXX_BATCH_REG 0x40

struct softmax_cxx_device {
	struct esp_device esp;
};

static struct esp_driver softmax_cxx_driver;

static struct of_device_id softmax_cxx_device_ids[] = {
	{
		.name = "SLD_SOFTMAX_CXX",
	},
	{
		.name = "eb_051",
	},
	{
		.compatible = "sld,softmax_cxx",
	},
	{ },
};

static int softmax_cxx_devs;

static inline struct softmax_cxx_device *to_softmax_cxx(struct esp_device *esp)
{
	return container_of(esp, struct softmax_cxx_device, esp);
}

static void softmax_cxx_prep_xfer(struct esp_device *esp, void *arg)
{
	struct softmax_cxx_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->batch, esp->iomem + SOFTMAX_CXX_BATCH_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool softmax_cxx_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct softmax_cxx_device *softmax_cxx = to_softmax_cxx(esp); */
	/* struct softmax_cxx_access *a = arg; */

	return true;
}

static int softmax_cxx_probe(struct platform_device *pdev)
{
	struct softmax_cxx_device *softmax_cxx;
	struct esp_device *esp;
	int rc;

	softmax_cxx = kzalloc(sizeof(*softmax_cxx), GFP_KERNEL);
	if (softmax_cxx == NULL)
		return -ENOMEM;
	esp = &softmax_cxx->esp;
	esp->module = THIS_MODULE;
	esp->number = softmax_cxx_devs;
	esp->driver = &softmax_cxx_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	softmax_cxx_devs++;
	return 0;
 err:
	kfree(softmax_cxx);
	return rc;
}

static int __exit softmax_cxx_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct softmax_cxx_device *softmax_cxx = to_softmax_cxx(esp);

	esp_device_unregister(esp);
	kfree(softmax_cxx);
	return 0;
}

static struct esp_driver softmax_cxx_driver = {
	.plat = {
		.probe		= softmax_cxx_probe,
		.remove		= softmax_cxx_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = softmax_cxx_device_ids,
		},
	},
	.xfer_input_ok	= softmax_cxx_xfer_input_ok,
	.prep_xfer	= softmax_cxx_prep_xfer,
	.ioctl_cm	= SOFTMAX_CXX_IOC_ACCESS,
	.arg_size	= sizeof(struct softmax_cxx_access),
};

static int __init softmax_cxx_init(void)
{
	return esp_driver_register(&softmax_cxx_driver);
}

static void __exit softmax_cxx_exit(void)
{
	esp_driver_unregister(&softmax_cxx_driver);
}

module_init(softmax_cxx_init)
module_exit(softmax_cxx_exit)

MODULE_DEVICE_TABLE(of, softmax_cxx_device_ids);

MODULE_AUTHOR("Giuseppe Di Guglielmo <giuseppe@cs.columbia.edu>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("softmax_cxx driver");
