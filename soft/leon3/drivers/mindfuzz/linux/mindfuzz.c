#include <linux/of_device.h>
#include <linux/mm.h>

#include <asm/io.h>

#include <esp_accelerator.h>
#include <esp.h>

#include "mindfuzz.h"

#define DRV_NAME	"mindfuzz"

/* <<--regs-->> */
#define MINDFUZZ_HIDDENS_PERWIN_REG 0x70
#define MINDFUZZ_WINDOW_SIZE_REG 0x6c
#define MINDFUZZ_RATE_VARIANCE_REG 0x68
#define MINDFUZZ_DO_INIT_REG 0x64
#define MINDFUZZ_DO_BACKPROP_REG 0x60
#define MINDFUZZ_ITERS_PERBATCH_REG 0x5c
#define MINDFUZZ_LEARNING_RATE_REG 0x58
#define MINDFUZZ_TSAMPS_PERBATCH_REG 0x54
#define MINDFUZZ_RATE_MEAN_REG 0x50
#define MINDFUZZ_BATCHES_PERLOAD_REG 0x4c
#define MINDFUZZ_DO_THRESH_UPDATE_REG 0x48
#define MINDFUZZ_NUM_WINDOWS_REG 0x44
#define MINDFUZZ_NUM_LOADS_REG 0x40

struct mindfuzz_device {
	struct esp_device esp;
};

static struct esp_driver mindfuzz_driver;

static struct of_device_id mindfuzz_device_ids[] = {
	{
		.name = "SLD_MINDFUZZ",
	},
	{
		.name = "eb_101",
	},
	{
		.compatible = "sld,mindfuzz",
	},
	{ },
};

static int mindfuzz_devs;

static inline struct mindfuzz_device *to_mindfuzz(struct esp_device *esp)
{
	return container_of(esp, struct mindfuzz_device, esp);
}

static void mindfuzz_prep_xfer(struct esp_device *esp, void *arg)
{
	struct mindfuzz_access *a = arg;

	/* <<--regs-config-->> */
	iowrite32be(a->hiddens_perwin, esp->iomem + MINDFUZZ_HIDDENS_PERWIN_REG);
	iowrite32be(a->window_size, esp->iomem + MINDFUZZ_WINDOW_SIZE_REG);
	iowrite32be(a->rate_variance, esp->iomem + MINDFUZZ_RATE_VARIANCE_REG);
	iowrite32be(a->do_init, esp->iomem + MINDFUZZ_DO_INIT_REG);
	iowrite32be(a->do_backprop, esp->iomem + MINDFUZZ_DO_BACKPROP_REG);
	iowrite32be(a->iters_perbatch, esp->iomem + MINDFUZZ_ITERS_PERBATCH_REG);
	iowrite32be(a->learning_rate, esp->iomem + MINDFUZZ_LEARNING_RATE_REG);
	iowrite32be(a->tsamps_perbatch, esp->iomem + MINDFUZZ_TSAMPS_PERBATCH_REG);
	iowrite32be(a->rate_mean, esp->iomem + MINDFUZZ_RATE_MEAN_REG);
	iowrite32be(a->batches_perload, esp->iomem + MINDFUZZ_BATCHES_PERLOAD_REG);
	iowrite32be(a->do_thresh_update, esp->iomem + MINDFUZZ_DO_THRESH_UPDATE_REG);
	iowrite32be(a->num_windows, esp->iomem + MINDFUZZ_NUM_WINDOWS_REG);
	iowrite32be(a->num_loads, esp->iomem + MINDFUZZ_NUM_LOADS_REG);
	iowrite32be(a->src_offset, esp->iomem + SRC_OFFSET_REG);
	iowrite32be(a->dst_offset, esp->iomem + DST_OFFSET_REG);

}

static bool mindfuzz_xfer_input_ok(struct esp_device *esp, void *arg)
{
	/* struct mindfuzz_device *mindfuzz = to_mindfuzz(esp); */
	/* struct mindfuzz_access *a = arg; */

	return true;
}

static int mindfuzz_probe(struct platform_device *pdev)
{
	struct mindfuzz_device *mindfuzz;
	struct esp_device *esp;
	int rc;

	mindfuzz = kzalloc(sizeof(*mindfuzz), GFP_KERNEL);
	if (mindfuzz == NULL)
		return -ENOMEM;
	esp = &mindfuzz->esp;
	esp->module = THIS_MODULE;
	esp->number = mindfuzz_devs;
	esp->driver = &mindfuzz_driver;
	rc = esp_device_register(esp, pdev);
	if (rc)
		goto err;

	mindfuzz_devs++;
	return 0;
 err:
	kfree(mindfuzz);
	return rc;
}

static int __exit mindfuzz_remove(struct platform_device *pdev)
{
	struct esp_device *esp = platform_get_drvdata(pdev);
	struct mindfuzz_device *mindfuzz = to_mindfuzz(esp);

	esp_device_unregister(esp);
	kfree(mindfuzz);
	return 0;
}

static struct esp_driver mindfuzz_driver = {
	.plat = {
		.probe		= mindfuzz_probe,
		.remove		= mindfuzz_remove,
		.driver		= {
			.name = DRV_NAME,
			.owner = THIS_MODULE,
			.of_match_table = mindfuzz_device_ids,
		},
	},
	.xfer_input_ok	= mindfuzz_xfer_input_ok,
	.prep_xfer	= mindfuzz_prep_xfer,
	.ioctl_cm	= MINDFUZZ_IOC_ACCESS,
	.arg_size	= sizeof(struct mindfuzz_access),
};

static int __init mindfuzz_init(void)
{
	return esp_driver_register(&mindfuzz_driver);
}

static void __exit mindfuzz_exit(void)
{
	esp_driver_unregister(&mindfuzz_driver);
}

module_init(mindfuzz_init)
module_exit(mindfuzz_exit)

MODULE_DEVICE_TABLE(of, mindfuzz_device_ids);

MODULE_AUTHOR("Emilio G. Cota <cota@braap.org>");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("mindfuzz driver");
