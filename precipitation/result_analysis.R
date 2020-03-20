options(stringsAsFactors = FALSE)
results_all_A = data.frame()
results_all_B = data.frame()
result_files = list.files(pattern = "RESULT.*.RData", full.names = TRUE)
for (f in result_files) {
  e = new.env()
  load(f, envir = e)
  M = e$model$M
  r = e$model$r
  model = substr(f, 25,26)
  results_all_A = rbind(results_all_A, (c(model = model, M=M,r=r, as.numeric(e$result_A_singlepart$measures))))
  colnames(results_all_A) <- c("model", "M","r", names(e$result_A_singlepart$measures))
  
  results_all_B = rbind(results_all_B, (c(model = model, M=M,r=r,  as.numeric(e$result_B_singlepart$measures))))
  colnames(results_all_B) <- c("model", "M","r", names(e$result_B_singlepart$measures))
}
for (i in 4:10) {
  results_all_A[,i] = as.numeric(results_all_A[,i])
  results_all_B[,i] = as.numeric(results_all_B[,i])
}

results_all = merge(results_all_A,results_all_B, by=c("model","M", "r"))
results_all[,c(10,17)] = round(results_all[,c(10,17)] / 60)

cnames = c("Model", "M", "r", "RMSE", "MAE", "COV2SD", "Runtime (min)", "RMSE", "MAE", "COV2SD", "Runtime (min)")
colnames(results_all) <- cnames
print(results_all)
