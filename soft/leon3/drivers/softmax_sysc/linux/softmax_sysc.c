#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "softmax_sysc.h"

#define DRV_NAME	"softmax_sysc"

/* <<--regs-->> */
#define SOFTMAX_SYSC_BATCH_REG 0x40

struct softmax_sysc_device {
	struct esp_device esp;
};

static struct esp_driver softmax_sysc_driver;

static struct of_device_id softmax_sysc_device_ids[] = {
	{
		.name = "SLD_SOFTMAX_SYSC",
	},
	{
		.name = "eb_050",
	},
	{
		.compatible = "sld,softmax_sysc",
	},
	{ },
};

static int softmax_sysc_devs;

static inline struct softmax_sysc_device *to_softmax_sysc(struct esp_device *esp)
{
	return container_of(esp, struct softmax_sysc_device, esp);
}

static void softmax_sysc_prep_xfer(struct esp_device *esp, void *arg)
{
	struct softmax_sysc_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->batch, esp->iomem + SOFTMAX_SYSC_BATCH_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool softmax_sysc_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct softmax_sysc_device *softmax_sysc = to_softmax_sysc(esp); */
	/* struct softmax_sysc_access *a = arg; */

	return true;
}

static int softmax_sysc_probe(struct platform_device *pdev)
{
	struct softmax_sysc_device *softmax_sysc;
	struct esp_device *esp;
	int rc;

	softmax_sysc = kzalloc(sizeof(*softmax_sysc), GFP_KERNEL);
	if (softmax_sysc == NULL)
		return -ENOMEM;
	esp = &softmax_sysc->esp;
	esp->module = THIS_MODULE;
	esp->number = softmax_sysc_devs;
	esp->driver = &softmax_sysc_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	softmax_sysc_devs++;
	return 0;
 err:
	kfree(softmax_sysc);
	return rc;
}

static int __exit softmax_sysc_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct softmax_sysc_device *softmax_sysc = to_softmax_sysc(esp);

	esp_device_unregister(esp);
	kfree(softmax_sysc);
	return 0;
}

static struct esp_driver softmax_sysc_driver = {
	.plat = {
		.probe		= softmax_sysc_probe,
		.remove		= softmax_sysc_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = softmax_sysc_device_ids,
		},
	},
	.xfer_input_ok	= softmax_sysc_xfer_input_ok,
	.prep_xfer	= softmax_sysc_prep_xfer,
	.ioctl_cm	= SOFTMAX_SYSC_IOC_ACCESS,
	.arg_size	= sizeof(struct softmax_sysc_access),
};

static int __init softmax_sysc_init(void)
{
	return esp_driver_register(&softmax_sysc_driver);
}

static void __exit softmax_sysc_exit(void)
{
	esp_driver_unregister(&softmax_sysc_driver);
}

module_init(softmax_sysc_init)
module_exit(softmax_sysc_exit)

MODULE_DEVICE_TABLE(of, softmax_sysc_device_ids);

MODULE_AUTHOR("Giuseppe Di Guglielmo <giuseppe@cs.columbia.edu>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("softmax_sysc driver");
