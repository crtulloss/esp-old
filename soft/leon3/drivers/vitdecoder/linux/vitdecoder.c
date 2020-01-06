#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "vitdecoder.h"

#define DRV_NAME	"vitdecoder"

/* <<--regs-->> */

struct vitdecoder_device {
	struct esp_device esp;
};

static struct esp_driver vitdecoder_driver;

static struct of_device_id vitdecoder_device_ids[] = {
	{
		.name = "SLD_VITDECODER",
	},
	{
		.name = "eb_/* <<--id-->> */",
	},
	{
		.compatible = "sld,vitdecoder",
	},
	{ },
};

static int vitdecoder_devs;

static inline struct vitdecoder_device *to_vitdecoder(struct esp_device *esp)
{
	return container_of(esp, struct vitdecoder_device, esp);
}

static void vitdecoder_prep_xfer(struct esp_device *esp, void *arg)
{
	struct vitdecoder_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool vitdecoder_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct vitdecoder_device *vitdecoder = to_vitdecoder(esp); */
	/* struct vitdecoder_access *a = arg; */

	return true;
}

static int vitdecoder_probe(struct platform_device *pdev)
{
	struct vitdecoder_device *vitdecoder;
	struct esp_device *esp;
	int rc;

	vitdecoder = kzalloc(sizeof(*vitdecoder), GFP_KERNEL);
	if (vitdecoder == NULL)
		return -ENOMEM;
	esp = &vitdecoder->esp;
	esp->module = THIS_MODULE;
	esp->number = vitdecoder_devs;
	esp->driver = &vitdecoder_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	vitdecoder_devs++;
	return 0;
 err:
	kfree(vitdecoder);
	return rc;
}

static int __exit vitdecoder_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct vitdecoder_device *vitdecoder = to_vitdecoder(esp);

	esp_device_unregister(esp);
	kfree(vitdecoder);
	return 0;
}

static struct esp_driver vitdecoder_driver = {
	.plat = {
		.probe		= vitdecoder_probe,
		.remove		= vitdecoder_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = vitdecoder_device_ids,
		},
	},
	.xfer_input_ok	= vitdecoder_xfer_input_ok,
	.prep_xfer	= vitdecoder_prep_xfer,
	.ioctl_cm	= VITDECODER_IOC_ACCESS,
	.arg_size	= sizeof(struct vitdecoder_access),
};

static int __init vitdecoder_init(void)
{
	return esp_driver_register(&vitdecoder_driver);
}

static void __exit vitdecoder_exit(void)
{
	esp_driver_unregister(&vitdecoder_driver);
}

module_init(vitdecoder_init)
module_exit(vitdecoder_exit)

MODULE_DEVICE_TABLE(of, vitdecoder_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("vitdecoder driver");
