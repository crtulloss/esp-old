#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "softmax.h"

#define DRV_NAME	"softmax"

/* <<--regs-->> */
#define SOFTMAX_SIZE_REG 0x44
#define SOFTMAX_BATCH_REG 0x40

struct softmax_device {
	struct esp_device esp;
};

static struct esp_driver softmax_driver;

static struct of_device_id softmax_device_ids[] = {
	{
		.name = "SLD_SOFTMAX",
	},
	{
		.name = "eb_050",
	},
	{
		.compatible = "sld,softmax",
	},
	{ },
};

static int softmax_devs;

static inline struct softmax_device *to_softmax(struct esp_device *esp)
{
	return container_of(esp, struct softmax_device, esp);
}

static void softmax_prep_xfer(struct esp_device *esp, void *arg)
{
	struct softmax_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->size, esp->iomem + SOFTMAX_SIZE_REG);
	iowrite32be(a->batch, esp->iomem + SOFTMAX_BATCH_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool softmax_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct softmax_device *softmax = to_softmax(esp); */
	/* struct softmax_access *a = arg; */

	return true;
}

static int softmax_probe(struct platform_device *pdev)
{
	struct softmax_device *softmax;
	struct esp_device *esp;
	int rc;

	softmax = kzalloc(sizeof(*softmax), GFP_KERNEL);
	if (softmax == NULL)
		return -ENOMEM;
	esp = &softmax->esp;
	esp->module = THIS_MODULE;
	esp->number = softmax_devs;
	esp->driver = &softmax_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	softmax_devs++;
	return 0;
 err:
	kfree(softmax);
	return rc;
}

static int __exit softmax_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct softmax_device *softmax = to_softmax(esp);

	esp_device_unregister(esp);
	kfree(softmax);
	return 0;
}

static struct esp_driver softmax_driver = {
	.plat = {
		.probe		= softmax_probe,
		.remove		= softmax_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = softmax_device_ids,
		},
	},
	.xfer_input_ok	= softmax_xfer_input_ok,
	.prep_xfer	= softmax_prep_xfer,
	.ioctl_cm	= SOFTMAX_IOC_ACCESS,
	.arg_size	= sizeof(struct softmax_access),
};

static int __init softmax_init(void)
{
	return esp_driver_register(&softmax_driver);
}

static void __exit softmax_exit(void)
{
	esp_driver_unregister(&softmax_driver);
}

module_init(softmax_init)
module_exit(softmax_exit)

MODULE_DEVICE_TABLE(of, softmax_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("softmax driver");
