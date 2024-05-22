function responsivelyAdjustFeaturedBannerHeadshotVisibility() {
    const bannerRow = document.querySelector('.researcherprofiles--featured-people-banner--row');
    if (!bannerRow) return;

    const immediateChildren = Array.from(bannerRow.children); // Convert to array for safe manipulation
    const images = Array.from(bannerRow.getElementsByTagName('img'));
    let totalWidth = 0;

    immediateChildren.forEach((elem, index, array) => {
        const isBadImage = elem.getAttribute('data-is-unloadable-image') === 'true';
        if (isBadImage) {
            elem.style.display = 'none';
        } else {
            elem.style.display = 'block'; // Reset display to calculate width
            if (elem.offsetWidth) {
                totalWidth += elem.offsetWidth + 0; // Include margin in pixels. In this case, 0.
                // If adding the current image exceeds the banner width, hide it and the rest
                if (totalWidth > bannerRow.offsetWidth) {
                    array.slice(index).forEach(hiddenElement => hiddenElement.style.display = 'none');
                }
            }
        }
    });
}

// Process as images load
document.addEventListener("DOMContentLoaded", function() {
    const bannerRow = document.querySelector('.researcherprofiles--featured-people-banner--row');
    if (!bannerRow) return;

    let images = Array.from(bannerRow.getElementsByTagName('img'));

    images.forEach(img => {
        // Image loaded? Recalculate
        img.onload = () => {
            responsivelyAdjustFeaturedBannerHeadshotVisibility();
        };

        // Error loading? Hide, and recalculate.
        img.onerror = () => {
            img.style.display = 'none';
            img.setAttribute('data-is-unloadable-image', 'true');
            responsivelyAdjustFeaturedBannerHeadshotVisibility();
        };

        // Image already loaded (e.g., cached)? Recalculate
        if (img.complete) {
            responsivelyAdjustFeaturedBannerHeadshotVisibility();
        }
    });
});

// Add event listener for window resize
window.addEventListener('resize', responsivelyAdjustFeaturedBannerHeadshotVisibility);