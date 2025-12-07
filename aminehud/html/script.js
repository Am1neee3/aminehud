$(document).ready(function () {
    let isEditMode = false;
    let hudVisible = true;

    window.addEventListener('message', function (event) {
        let data = event.data;

        if (data.action === "updateStatus") {
            // Update Status Bars
            setProgress("#health-fill", data.health);
            setProgress("#armor-fill", data.armor);
            setProgress("#hunger-fill", data.hunger);
            setProgress("#thirst-fill", data.thirst);
            setProgress("#stamina-fill", data.stamina);

            // Hide/Show items based on config (data.config should optionally be passed or handled by CSS classes)
            // For now assuming all are active or handled by visibility styles in CSS if 0
            if (data.armor <= 0) {
                // optionally hide armor if 0
                // $("#armor-wrapper").fadeOut(); 
                // But user usually wants to see 0 armor.
            } else {
                // $("#armor-wrapper").fadeIn();
            }
        }
        else if (data.action === "vehicleUpdate") {
            if (data.inVehicle) {
                $("#car-container").fadeIn();
                $("#speed-amount").text(data.speed);
                $("#speed-unit").text(data.speedUnit);
                $("#fuel-amount").text(Math.round(data.fuel) + "%");
                $("#engine-amount").text(Math.round(data.engine / 10) + "%"); // Engine is usually 0-1000
            } else {
                $("#car-container").fadeOut();
            }
        }
        else if (data.action === "toggleHud") {
            hudVisible = !hudVisible;
            if (hudVisible) {
                $("#hud-container").fadeIn();
            } else {
                $("#hud-container").fadeOut();
            }
        }
        else if (data.action === "toggleEditMode") {
            toggleEditMode();
        }
    });

    function setProgress(selector, value) {
        if (value < 0) value = 0;
        if (value > 100) value = 100;
        $(selector).css("width", value + "%");
    }

    // Drag and Drop Logic
    function toggleEditMode() {
        isEditMode = !isEditMode;
        if (isEditMode) {
            $("body").addClass("is-editing");
            $(".hud-group").addClass("edit-mode-active").addClass("draggable");
            enableDrag();
        } else {
            $("body").removeClass("is-editing");
            $(".hud-group").removeClass("edit-mode-active").removeClass("draggable");
            disableDrag();
            savePositions();
            // Tell Lua we are done
            $.post("https://aminehud/closeEditMode", JSON.stringify({}));
        }
    }

    function enableDrag() {
        $(".draggable").mousedown(function (e) {
            e.preventDefault();
            let dragEl = $(this);
            let offset = dragEl.offset();
            let shiftX = e.pageX - offset.left;
            let shiftY = e.pageY - offset.top;

            $(document).mousemove(function (e) {
                let left = e.pageX - shiftX;
                let top = e.pageY - shiftY;

                // Bounds checking to keep inside screen
                let maxLeft = $(window).width() - dragEl.outerWidth();
                let maxTop = $(window).height() - dragEl.outerHeight();

                // if (left < 0) left = 0;
                // if (top < 0) top = 0;
                // if (left > maxLeft) left = maxLeft;
                // if (top > maxTop) top = maxTop;

                // For "bottom right" style positioning, we usually adjust 'left' and 'top' styles.
                // However, our CSS uses 'bottom' and 'right' in some cases.
                // It's easiest to switch to 'left' and 'top' for dragging and save those.

                dragEl.css({
                    bottom: 'auto',
                    right: 'auto',
                    left: left + 'px',
                    top: top + 'px'
                });
            });

            $(document).mouseup(function () {
                $(document).off("mousemove");
                $(document).off("mouseup");
            });
        });
    }

    function disableDrag() {
        $(".draggable").off("mousedown");
    }

    function savePositions() {
        // Collect positions
        let positions = {};
        $(".hud-group").each(function () {
            let id = $(this).attr("id");
            let pos = $(this).position();
            // Convert to percentages for responsiveness? Or keep px.
            // Px is safer for drag/drop on same resolution.
            positions[id] = {
                left: pos.left,
                top: pos.top
            };
        });

        // Save via Lua (Optional: Persist to KV store or json file via callback)
        $.post("https://aminehud/savePositions", JSON.stringify(positions));
    }

    // Key Listener for Edit Mode Exit (Enter)
    $(document).keydown(function (e) {
        if (isEditMode && e.key === "Enter") {
            toggleEditMode();
        }
    });

    // Initial load positions if saved? 
    // Usually passed via "loadPositions" action from Lua on start.
});
