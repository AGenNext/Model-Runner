use anyhow::Result;
use dirs::home_dir;
use eframe::egui;
use rfd::FileDialog;
use std::fs::{self, File};
use std::io::copy;
use std::path::{Path, PathBuf};
use std::process::Command;
use walkdir::WalkDir;

const DEFAULT_MODEL_NAME: &str = "tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf";
const DEFAULT_MODEL_URL: &str = "https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf";

fn main() -> Result<()> {
    let options = eframe::NativeOptions::default();

    eframe::run_native(
        "Model Runner",
        options,
        Box::new(|_cc| Box::new(App::default())),
    )
    .map_err(|e| anyhow::anyhow!(e.to_string()))?;

    Ok(())
}

struct App {
    models: Vec<PathBuf>,
    selected: Option<PathBuf>,
    status: String,
}

impl Default for App {
    fn default() -> Self {
        let models = scan_models();

        Self {
            selected: models.first().cloned(),
            models,
            status: String::new(),
        }
    }
}

impl eframe::App for App {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            ui.heading("Model Runner");

            if self.models.is_empty() {
                ui.label("No GGUF models found.");
            } else {
                ui.label("Detected models:");

                for model in &self.models {
                    let label = model
                        .file_name()
                        .map(|v| v.to_string_lossy().to_string())
                        .unwrap_or_else(|| model.display().to_string());

                    if ui
                        .selectable_label(self.selected.as_ref() == Some(model), label)
                        .clicked()
                    {
                        self.selected = Some(model.clone());
                    }
                }
            }

            ui.separator();

            if ui.button("Choose GGUF File").clicked() {
                if let Some(path) = FileDialog::new().add_filter("GGUF", &["gguf"]).pick_file() {
                    self.selected = Some(path.clone());
                    if !self.models.contains(&path) {
                        self.models.push(path);
                    }
                }
            }

            if ui.button("Download TinyLlama GGUF").clicked() {
                match download_default_model() {
                    Ok(path) => {
                        self.selected = Some(path.clone());
                        self.models = scan_models();
                        if !self.models.contains(&path) {
                            self.models.push(path);
                        }
                        self.status = "Model downloaded".to_string();
                    }
                    Err(err) => self.status = err.to_string(),
                }
            }

            if ui.button("Start Model Runner").clicked() {
                match start_runner(self.selected.as_ref()) {
                    Ok(_) => self.status = "Model Runner started".to_string(),
                    Err(err) => self.status = err.to_string(),
                }
            }

            if !self.status.is_empty() {
                ui.separator();
                ui.label(&self.status);
            }
        });
    }
}

fn model_dir() -> Result<PathBuf> {
    let home = home_dir().ok_or_else(|| anyhow::anyhow!("Could not find home directory"))?;
    Ok(home.join("Models").join("Model-Runner"))
}

fn download_default_model() -> Result<PathBuf> {
    let dir = model_dir()?;
    fs::create_dir_all(&dir)?;

    let target = dir.join(DEFAULT_MODEL_NAME);
    if target.exists() {
        return Ok(target);
    }

    let response = ureq::get(DEFAULT_MODEL_URL).call()?;
    let mut reader = response.into_reader();
    let mut file = File::create(&target)?;
    copy(&mut reader, &mut file)?;

    Ok(target)
}

fn scan_models() -> Vec<PathBuf> {
    let mut roots = Vec::new();

    if let Some(home) = home_dir() {
        roots.push(home.join("Models"));
        roots.push(home.join("Downloads"));
        roots.push(home.join("Documents"));
        roots.push(home.join(".cache/huggingface"));
        roots.push(home.join(".lmstudio/models"));
    }

    roots.push(PathBuf::from("./models"));

    let mut found = Vec::new();

    for root in roots {
        if !root.exists() {
            continue;
        }

        for entry in WalkDir::new(root)
            .follow_links(true)
            .max_depth(8)
            .into_iter()
            .filter_map(Result::ok)
        {
            let path = entry.path();

            if path
                .extension()
                .map(|e| e.eq_ignore_ascii_case("gguf"))
                .unwrap_or(false)
            {
                found.push(path.to_path_buf());
            }
        }
    }

    found.sort();
    found.dedup();
    found
}

fn start_runner(model: Option<&PathBuf>) -> Result<()> {
    let model = model.ok_or_else(|| anyhow::anyhow!("No model selected"))?;

    let model_dir = model
        .parent()
        .ok_or_else(|| anyhow::anyhow!("Invalid model path"))?;

    let model_name = model
        .file_name()
        .ok_or_else(|| anyhow::anyhow!("Invalid model name"))?
        .to_string_lossy()
        .to_string();

    Command::new("podman")
        .args([
            "run",
            "--rm",
            "-p",
            "8080:8080",
            "-v",
            &format!("{}:/models", model_dir.display()),
            "-e",
            &format!("MODEL=/models/{model_name}"),
            "model-runner",
        ])
        .spawn()?;

    Ok(())
}
