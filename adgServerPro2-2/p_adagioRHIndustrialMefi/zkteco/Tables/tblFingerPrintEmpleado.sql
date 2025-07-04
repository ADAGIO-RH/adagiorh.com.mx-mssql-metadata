USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[tblFingerPrintEmpleado](
	[IDFingerPrintEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Content] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaReg] [datetime] NOT NULL,
 CONSTRAINT [PK_zktecoTblFingerPrintEmpleado_IDFingerPrintEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDFingerPrintEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [zkteco].[tblFingerPrintEmpleado] ADD  CONSTRAINT [U_zktecoTblFingerPrintEmpleado_FechaReg]  DEFAULT (getdate()) FOR [FechaReg]
GO
ALTER TABLE [zkteco].[tblFingerPrintEmpleado]  WITH CHECK ADD  CONSTRAINT [PK_zktecoTblFingerPrintEmpleado_RHTblEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [zkteco].[tblFingerPrintEmpleado] CHECK CONSTRAINT [PK_zktecoTblFingerPrintEmpleado_RHTblEmpleados_IDEmpleado]
GO
