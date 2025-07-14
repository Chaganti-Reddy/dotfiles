const links = {
  a: "https://github.com",
  c: "https://chatgpt.com",
  s: "https://youtube.com",
  d: "https://reddit.com", 
  g: "https://tldraw.com",
};

/**
 * @param {string} key
 * @returns {string}
 * */
const key_to_letter = (key) => {
  return key[key.length - 1].toLowerCase().toString();
};

document.addEventListener("DOMContentLoaded", () => {
  window.addEventListener("keypress", (e) => {
    const link = links[key_to_letter(e.code)];
    if (link) {
      window.location.href = link;
    }
  });

  const list_element = document.getElementById("list");
  for (const [key, value] of Object.entries(links)) {
    let list_item = document.createElement("li");
    let list_link = document.createElement("a");

    let display_title = "nan";
    if (typeof value === "object") {
      display_title = value.alias;
    } else {
      display_title = value
        .replace("https://", "")
        .replace(/\.[a-zA-Z0-9]+$/, "");
    }

    list_link.innerText = `[${key}] ${display_title}`;
    list_link.value = value;
    list_link.href = value;

    list_item.appendChild(list_link);
    list_element.appendChild(list_item);
  }
});
